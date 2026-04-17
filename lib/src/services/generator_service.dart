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
  });

  final String projectName;
  final String organization;
  final String description;
  final String templateId;
  final String brickPath;
  final String targetDir;
  final List<String> features;
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
    await generator.generate(
      DirectoryGeneratorTarget(targetDir),
      vars: <String, dynamic>{
        'project_name': request.projectName,
        'organization': request.organization,
        'description': request.description,
      },
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
