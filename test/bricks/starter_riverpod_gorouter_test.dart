import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('starter_riverpod_gorouter brick', () {
    const brickRoot = 'bricks/starter_riverpod_gorouter';

    test('brick.yaml exists and declares required variables', () {
      final file = File('$brickRoot/brick.yaml');
      expect(file.existsSync(), isTrue, reason: 'Missing brick.yaml');

      final doc = loadYaml(file.readAsStringSync()) as YamlMap;
      expect(doc['name'], 'starter_riverpod_gorouter');
      expect(doc['version'], isNotNull);

      final vars = doc['vars'] as YamlMap;
      for (final key in const <String>[
        'project_name',
        'organization',
        'description',
      ]) {
        expect(vars[key], isNotNull, reason: 'Missing var: $key');
      }
    });

    test('all expected template files exist', () {
      const required = <String>[
        'pubspec.yaml',
        'analysis_options.yaml',
        'README.md',
        'lib/main.dart',
        'lib/app/app.dart',
        'lib/app/router.dart',
        'lib/app/theme.dart',
        'lib/features/home/home_screen.dart',
        'lib/features/about/about_screen.dart',
        'test/widget_test.dart',
      ];

      for (final path in required) {
        final file = File('$brickRoot/__brick__/$path');
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Missing: __brick__/$path',
        );
      }
    });

    test('templated files reference mustache variables', () {
      final pubspec =
          File('$brickRoot/__brick__/pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('{{project_name}}'));
      expect(pubspec, contains('{{description}}'));

      final readme = File('$brickRoot/__brick__/README.md').readAsStringSync();
      expect(readme, contains('{{project_name'));
      expect(readme, contains('{{description}}'));

      final widgetTest =
          File('$brickRoot/__brick__/test/widget_test.dart').readAsStringSync();
      expect(widgetTest, contains('package:{{project_name}}'));
    });
  });
}
