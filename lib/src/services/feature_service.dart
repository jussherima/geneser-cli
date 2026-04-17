import 'dart:io';

import 'package:mason/mason.dart'
    show
        Brick,
        DirectoryGeneratorTarget,
        FileConflictResolution,
        MasonGenerator;
import 'package:mason_logger/mason_logger.dart';

import '../models/feature.dart';
import 'generator_service.dart';
import 'project_manifest_service.dart';

class FeatureApplicationResult {
  const FeatureApplicationResult._({required this.success, this.error});

  const FeatureApplicationResult.success() : this._(success: true);

  const FeatureApplicationResult.failure(String error)
      : this._(success: false, error: error);

  final bool success;
  final String? error;
}

/// Applies a feature brick on top of an existing Geneser project and updates
/// the project's manifest.
class FeatureService {
  FeatureService({
    Logger? logger,
    ProjectManifestService? manifestService,
  })  : _logger = logger ?? Logger(),
        _manifestService = manifestService ?? ProjectManifestService();

  final Logger _logger;
  final ProjectManifestService _manifestService;

  Future<FeatureApplicationResult> apply({
    required String projectDir,
    required Feature feature,
    required String brickPath,
  }) async {
    if (!Directory(projectDir).existsSync()) {
      return FeatureApplicationResult.failure(
        'Project directory does not exist: $projectDir',
      );
    }
    if (!Directory(brickPath).existsSync()) {
      return FeatureApplicationResult.failure(
        'Feature brick not found at $brickPath',
      );
    }

    final progress = _logger.progress('Applying ${feature.name}');
    try {
      final manifest = _manifestService.read(projectDir);
      final brick = Brick.path(brickPath);
      final generator = await MasonGenerator.fromBrick(brick);

      await generator.generate(
        DirectoryGeneratorTarget(Directory(projectDir)),
        vars: <String, dynamic>{
          'project_name': manifest?.projectName ?? 'my_app',
          'organization': manifest?.organization ?? 'com.example',
        },
        fileConflictResolution: FileConflictResolution.skip,
      );

      if (manifest != null && !manifest.features.contains(feature.id)) {
        final updated = manifest.copyWith(
          features: <String>[...manifest.features, feature.id],
        );
        _manifestService.write(projectDir, updated);
      }

      progress.complete('${feature.name} applied');
      return const FeatureApplicationResult.success();
    } on Exception catch (e) {
      progress.fail('${feature.name} failed: $e');
      return FeatureApplicationResult.failure(e.toString());
    }
  }

  /// Resolve the on-disk location of a feature brick. Delegates to the same
  /// logic that templates use, since both live under `bricks/<id>`.
  static String resolveFeatureBrickPath(String featureId) {
    return GeneratorService.resolveBrickPath(featureId);
  }
}
