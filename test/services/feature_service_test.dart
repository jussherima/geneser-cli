import 'dart:io';

import 'package:geneser/src/models/feature.dart';
import 'package:geneser/src/models/project_manifest.dart';
import 'package:geneser/src/services/feature_service.dart';
import 'package:geneser/src/services/project_manifest_service.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _feature = Feature(
  id: 'theming_dark_light',
  name: 'Dark / Light theming',
  description: 'Theme toggle.',
);

void main() {
  group('FeatureService', () {
    test('fails when project directory does not exist', () async {
      final service = FeatureService();
      final result = await service.apply(
        projectDir: '/does/not/exist',
        feature: _feature,
        brickPath: 'bricks/theming_dark_light',
      );
      expect(result.success, isFalse);
      expect(result.error, contains('Project directory'));
    });

    test('fails when feature brick is missing', () async {
      final tempDir = await Directory.systemTemp.createTemp('feature_test_');
      try {
        final service = FeatureService();
        final result = await service.apply(
          projectDir: tempDir.path,
          feature: _feature,
          brickPath: '/no/such/brick',
        );
        expect(result.success, isFalse);
        expect(result.error, contains('not found'));
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('applies a feature brick and updates the manifest', () async {
      final tempDir = await Directory.systemTemp.createTemp('feature_test_');
      try {
        final manifestService = ProjectManifestService();
        manifestService.write(
          tempDir.path,
          const ProjectManifest(
            geneserVersion: '0.1.0',
            templateId: 'starter_riverpod_gorouter',
            projectName: 'test_app',
            organization: 'com.example',
            features: <String>[],
          ),
        );

        final service = FeatureService();
        final result = await service.apply(
          projectDir: tempDir.path,
          feature: _feature,
          brickPath: 'bricks/theming_dark_light',
        );

        expect(result.success, isTrue, reason: result.error);

        // Files generated
        expect(
          File(
            p.join(
              tempDir.path,
              'lib/features/settings/settings_screen.dart',
            ),
          ).existsSync(),
          isTrue,
        );

        // Manifest updated
        final manifest = manifestService.read(tempDir.path);
        expect(manifest?.features, contains(_feature.id));
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });
}
