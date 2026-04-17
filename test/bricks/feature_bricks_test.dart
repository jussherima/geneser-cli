import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('theming_dark_light brick', () {
    const brickRoot = 'bricks/theming_dark_light';

    test('brick.yaml exists with name and version', () {
      final file = File('$brickRoot/brick.yaml');
      expect(file.existsSync(), isTrue);
      final doc = loadYaml(file.readAsStringSync()) as YamlMap;
      expect(doc['name'], 'theming_dark_light');
      expect(doc['version'], isNotNull);
    });

    test('template files exist', () {
      for (final path in const <String>[
        'lib/features/settings/settings_screen.dart',
        'lib/features/settings/theme_controller.dart',
      ]) {
        expect(
          File('$brickRoot/__brick__/$path').existsSync(),
          isTrue,
          reason: 'Missing $path',
        );
      }
    });
  });

  group('auth_firebase brick', () {
    const brickRoot = 'bricks/auth_firebase';

    test('brick.yaml exists with name and version', () {
      final file = File('$brickRoot/brick.yaml');
      expect(file.existsSync(), isTrue);
      final doc = loadYaml(file.readAsStringSync()) as YamlMap;
      expect(doc['name'], 'auth_firebase');
      expect(doc['version'], isNotNull);
    });

    test('template files exist', () {
      for (final path in const <String>[
        'lib/features/auth/auth_repository.dart',
        'lib/features/auth/in_memory_auth_repository.dart',
        'lib/features/auth/auth_provider.dart',
        'lib/features/auth/login_screen.dart',
      ]) {
        expect(
          File('$brickRoot/__brick__/$path').existsSync(),
          isTrue,
          reason: 'Missing $path',
        );
      }
    });
  });
}
