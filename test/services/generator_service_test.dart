import 'dart:io';

import 'package:geneser/src/services/generator_service.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('GeneratorService', () {
    test('returns failure when target directory is not empty', () async {
      final tempDir = await Directory.systemTemp.createTemp('gen_test_');
      File(p.join(tempDir.path, 'existing.txt')).writeAsStringSync('hi');

      try {
        final service = GeneratorService();
        final result = await service.generate(
          GenerationRequest(
            projectName: 'test_app',
            organization: 'com.example',
            description: 'test',
            templateId: 'some_template',
            brickPath: '/does/not/matter',
            targetDir: tempDir.path,
          ),
        );

        expect(result.success, isFalse);
        expect(result.error, contains('not empty'));
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('returns failure when brick path does not exist', () async {
      final tempDir = await Directory.systemTemp.createTemp('gen_test_');
      try {
        final service = GeneratorService();
        final result = await service.generate(
          GenerationRequest(
            projectName: 'test_app',
            organization: 'com.example',
            description: 'test',
            templateId: 'some_template',
            brickPath: '/definitely/not/a/real/path',
            targetDir: p.join(tempDir.path, 'new_project'),
          ),
        );

        expect(result.success, isFalse);
        expect(result.error, contains('Brick not found'));
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('resolveBrickPath returns a non-empty string', () {
      final path = GeneratorService.resolveBrickPath('any_id');
      expect(path, isNotEmpty);
      expect(path, endsWith('any_id'));
    });
  });
}
