import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Mason brick generation', () {
    test(
      'starter_riverpod_gorouter generates files with substituted vars',
      () async {
        final brickDir = Directory('bricks/starter_riverpod_gorouter');
        expect(
          brickDir.existsSync(),
          isTrue,
          reason: 'Brick not found — run tests from the repo root.',
        );

        final brick = Brick.path(brickDir.path);
        final generator = await MasonGenerator.fromBrick(brick);
        final tempDir = await Directory.systemTemp.createTemp('mason_test_');

        try {
          await generator.generate(
            DirectoryGeneratorTarget(tempDir),
            vars: <String, dynamic>{
              'project_name': 'test_app',
              'organization': 'com.example',
              'description': 'Test project',
            },
            fileConflictResolution: FileConflictResolution.overwrite,
          );

          // Core files exist
          final expectedFiles = <String>[
            'pubspec.yaml',
            'analysis_options.yaml',
            'README.md',
            p.join('lib', 'main.dart'),
            p.join('lib', 'app', 'app.dart'),
            p.join('lib', 'app', 'router.dart'),
            p.join('lib', 'app', 'theme.dart'),
            p.join('lib', 'features', 'home', 'home_screen.dart'),
            p.join('lib', 'features', 'about', 'about_screen.dart'),
            p.join('test', 'widget_test.dart'),
          ];
          for (final relative in expectedFiles) {
            expect(
              File(p.join(tempDir.path, relative)).existsSync(),
              isTrue,
              reason: 'Expected file missing: $relative',
            );
          }

          // Variable substitution in pubspec
          final pubspec =
              File(p.join(tempDir.path, 'pubspec.yaml')).readAsStringSync();
          expect(pubspec, contains('name: test_app'));
          expect(pubspec, contains('Test project'));
          expect(pubspec, isNot(contains('{{')));

          // Package name substituted in imports
          final widgetTest = File(
            p.join(tempDir.path, 'test', 'widget_test.dart'),
          ).readAsStringSync();
          expect(widgetTest, contains('package:test_app/app/app.dart'));
          expect(widgetTest, isNot(contains('{{')));

          // titleCase filter applied
          final app = File(p.join(tempDir.path, 'lib', 'app', 'app.dart'))
              .readAsStringSync();
          expect(app, isNot(contains('{{')));
          expect(app, contains('Test App'));
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );
  });
}
