import 'dart:io';

import 'package:mason/mason.dart'
    show
        Brick,
        DirectoryGeneratorTarget,
        FileConflictResolution,
        MasonGenerator;
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

import '../models/project_manifest.dart';
import '../version.dart';
import 'project_manifest_service.dart';

class GenerationRequest {
  const GenerationRequest({
    required this.projectName,
    required this.organization,
    required this.description,
    required this.templateId,
    required this.brickPath,
    required this.targetDir,
    this.features = const <String>[],
    this.vars = const <String, dynamic>{},
  });

  final String projectName;
  final String organization;
  final String description;
  final String templateId;
  final String brickPath;
  final String targetDir;
  final List<String> features;

  /// Extra vars from brick.yaml (with_backend, backend_provider, with_initializer, etc.)
  final Map<String, dynamic> vars;
}

class GenerationResult {
  const GenerationResult._({
    required this.success,
    required this.outputPath,
    this.error,
  });

  const GenerationResult.success(String path)
      : this._(success: true, outputPath: path);

  const GenerationResult.failure(String path, String error)
      : this._(success: false, outputPath: path, error: error);

  final bool success;
  final String outputPath;
  final String? error;
}

/// Orchestrates end-to-end project generation:
///   1. `flutter create` (platform scaffolding)
///   2. Mason overlay (our templated files)
///   3. `.geneser.yaml` manifest
///   4. `flutter pub get`
///   5. `git init` + first commit
class GeneratorService {
  GeneratorService({
    Logger? logger,
    ProjectManifestService? manifestService,
  })  : _logger = logger ?? Logger(),
        _manifestService = manifestService ?? ProjectManifestService();

  final Logger _logger;
  final ProjectManifestService _manifestService;

  Future<GenerationResult> generate(GenerationRequest request) async {
    final targetDir = Directory(request.targetDir);

    if (targetDir.existsSync() && targetDir.listSync().isNotEmpty) {
      return GenerationResult.failure(
        request.targetDir,
        'Target directory "${request.targetDir}" is not empty.',
      );
    }

    final brickDir = Directory(request.brickPath);
    if (!brickDir.existsSync()) {
      return GenerationResult.failure(
        request.targetDir,
        'Brick not found at "${request.brickPath}".',
      );
    }

    try {
      targetDir.createSync(recursive: true);
      await _runFlutterCreate(request);
      await _applyBrick(request, targetDir);
      _writeManifest(request);
      await _runFlutterPubGet(request.targetDir);
      await _initializeGit(request.targetDir);
      return GenerationResult.success(request.targetDir);
    } on Exception catch (e) {
      return GenerationResult.failure(request.targetDir, e.toString());
    }
  }

  Future<void> _runFlutterCreate(GenerationRequest request) async {
    final progress = _logger.progress('Running flutter create');
    final result = await Process.run(
      'flutter',
      <String>[
        'create',
        '.',
        '--project-name',
        request.projectName,
        '--org',
        request.organization,
        '--platforms',
        'android,ios,web',
      ],
      workingDirectory: request.targetDir,
    );
    if (result.exitCode != 0) {
      progress.fail('flutter create failed');
      throw Exception(
        'flutter create exited with code ${result.exitCode}: ${result.stderr}',
      );
    }
    progress.complete('Flutter scaffolding ready');
  }

  Future<void> _applyBrick(
    GenerationRequest request,
    Directory targetDir,
  ) async {
    final progress = _logger.progress('Applying template');
    final brick = Brick.path(request.brickPath);
    final generator = await MasonGenerator.fromBrick(brick);
    // Base vars + extra vars from brick.yaml, plus derived helpers for mustache
    final baseVars = <String, dynamic>{
      'project_name': request.projectName,
      'organization': request.organization,
      'description': request.description,
      ...request.vars,
    };
    // --- Derive helpers for cwa_clean v0.3 (array checkbox + enum backend) ---
    // Environments array -> with_env_*
    final envs = (baseVars['environments'] as List?)?.map((e) => e.toString()).toList();
    if (envs != null) {
      baseVars['with_env_dev'] = envs.contains('dev');
      baseVars['with_env_prod'] = envs.contains('prod');
      baseVars['with_env_local'] = envs.contains('local');
      baseVars['with_env_stg'] = envs.contains('stg');
    }
    // Features array -> with_* booleans
    final feats = (baseVars['features'] as List?)?.map((e) => e.toString()).toList();
    if (feats != null) {
      baseVars['with_auth'] = feats.contains('auth');
      baseVars['with_feed'] = feats.contains('feed');
      baseVars['with_notifications'] = feats.contains('notifications');
      baseVars['with_profile'] = feats.contains('profile');
      baseVars['with_language_settings'] = feats.contains('language_settings');
      baseVars['with_drift'] = feats.contains('drift');
      baseVars['with_i18n'] = feats.contains('i18n');
    }
    // Backend enum [none,firebase,supabase,rest_api] -> booleans
    final backend = baseVars['backend'] as String? ?? baseVars['backend_provider'] as String? ?? 'none';
    baseVars['backend'] = backend;
    baseVars['backend_provider'] = backend; // compat
    final withBackend = backend != 'none';
    baseVars['with_backend'] = withBackend;
    baseVars['backend_is_firebase'] = backend == 'firebase';
    baseVars['backend_is_supabase'] = backend == 'supabase';
    baseVars['backend_is_rest'] = backend == 'rest_api';

    // Ensure defaults for cwa_clean v0.3
    baseVars.putIfAbsent('app_name', () => request.projectName);
    baseVars.putIfAbsent('bundle_id', () => '');
    baseVars.putIfAbsent('backend_url', () => 'https://api.example.com');
    baseVars.putIfAbsent('primary_color', () => '0xFF0E7A4B');
    baseVars.putIfAbsent('environments', () => ['dev', 'prod']);
    baseVars.putIfAbsent('features', () => ['feed', 'profile']);
    baseVars.putIfAbsent('backend', () => 'none');
    baseVars.putIfAbsent('with_drift', () => (baseVars['features'] as List?)?.contains('drift') ?? true);
    baseVars.putIfAbsent('with_i18n', () => (baseVars['features'] as List?)?.contains('i18n') ?? true);
    // Fallback booleans for old callers
    baseVars.putIfAbsent('with_env_dev', () => true);
    baseVars.putIfAbsent('with_env_prod', () => true);
    baseVars.putIfAbsent('with_env_local', () => false);
    baseVars.putIfAbsent('with_env_stg', () => false);
    baseVars.putIfAbsent('with_auth', () => false);
    baseVars.putIfAbsent('with_notifications', () => true);
    baseVars.putIfAbsent('with_feed', () => true);
    baseVars.putIfAbsent('with_profile', () => true);
    baseVars.putIfAbsent('with_language_settings', () => true);

    await generator.generate(
      DirectoryGeneratorTarget(targetDir),
      vars: baseVars,
      fileConflictResolution: FileConflictResolution.overwrite,
    );
    progress.complete('Template applied');
  }

  void _writeManifest(GenerationRequest request) {
    _manifestService.write(
      request.targetDir,
      ProjectManifest(
        geneserVersion: packageVersion,
        templateId: request.templateId,
        projectName: request.projectName,
        organization: request.organization,
        features: request.features,
      ),
    );
  }

  Future<void> _runFlutterPubGet(String targetDir) async {
    final progress = _logger.progress('Running flutter pub get');
    final result = await Process.run(
      'flutter',
      <String>['pub', 'get'],
      workingDirectory: targetDir,
    );
    if (result.exitCode != 0) {
      progress.fail(
        'flutter pub get failed (retry with: cd $targetDir && flutter pub get)',
      );
      return;
    }
    progress.complete('Dependencies resolved');
  }

  Future<void> _initializeGit(String targetDir) async {
    final progress = _logger.progress('Initializing git');
    final init = await Process.run(
      'git',
      <String>['init', '--quiet'],
      workingDirectory: targetDir,
    );
    if (init.exitCode != 0) {
      progress.fail('Git init failed (non-blocking)');
      return;
    }
    await Process.run(
      'git',
      <String>['add', '.'],
      workingDirectory: targetDir,
    );
    await Process.run(
      'git',
      <String>[
        'commit',
        '-m',
        'chore: initial commit from Geneser',
        '--quiet',
      ],
      workingDirectory: targetDir,
    );
    progress.complete('Git repository initialized');
  }

  /// Resolve the brick path for a given template or feature id.
  ///
  /// Resolution order:
  ///   1. `GENESER_BRICKS_DIR` environment variable (explicit override).
  ///   2. Walking up from the script location looking for `bricks/<id>`.
  ///   3. `./bricks/<id>` relative to the current working directory.
  static String resolveBrickPath(String brickId) {
    final override = Platform.environment['GENESER_BRICKS_DIR'];
    if (override != null && override.isNotEmpty) {
      return p.join(override, brickId);
    }

    final scriptPath = Platform.script.toFilePath();
    var dir = Directory(p.dirname(scriptPath));
    for (var i = 0; i < 6; i++) {
      final candidate = Directory(p.join(dir.path, 'bricks', brickId));
      if (candidate.existsSync()) return candidate.path;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }

    return p.join(Directory.current.path, 'bricks', brickId);
  }
}
