import 'dart:io';

import 'package:geneser/src/models/project_manifest.dart';
import 'package:geneser/src/services/project_manifest_service.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectManifestService', () {
    late Directory tempDir;
    late ProjectManifestService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('manifest_test_');
      service = ProjectManifestService();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('returns null when manifest is missing', () {
      expect(service.read(tempDir.path), isNull);
    });

    test('write and read round-trip preserves all fields', () {
      final original = ProjectManifest(
        geneserVersion: '0.1.0',
        templateId: 'starter_riverpod_gorouter',
        projectName: 'my_app',
        organization: 'com.example',
        features: const <String>['auth_firebase', 'theming_dark_light'],
      );

      service.write(tempDir.path, original);
      final restored = service.read(tempDir.path);

      expect(restored, isNotNull);
      expect(restored!.geneserVersion, '0.1.0');
      expect(restored.templateId, 'starter_riverpod_gorouter');
      expect(restored.projectName, 'my_app');
      expect(restored.organization, 'com.example');
      expect(restored.features, original.features);
    });

    test('handles empty features list', () {
      final original = ProjectManifest(
        geneserVersion: '0.1.0',
        templateId: 't',
        projectName: 'p',
        organization: 'com.example',
        features: const <String>[],
      );
      service.write(tempDir.path, original);
      final restored = service.read(tempDir.path);
      expect(restored?.features, isEmpty);
    });

    test('returns null for malformed YAML', () {
      final file = File('${tempDir.path}/${ProjectManifestService.fileName}')
        ..writeAsStringSync('this is not: valid: yaml: garbage');
      expect(file.existsSync(), isTrue);
      expect(service.read(tempDir.path), isNull);
    });

    test('copyWith replaces features only when provided', () {
      final manifest = ProjectManifest(
        geneserVersion: '0.1.0',
        templateId: 't',
        projectName: 'p',
        organization: 'o.x',
        features: const <String>['a'],
      );
      final updated = manifest.copyWith(features: const <String>['a', 'b']);
      expect(updated.features, <String>['a', 'b']);
      expect(updated.projectName, manifest.projectName);
    });
  });
}
