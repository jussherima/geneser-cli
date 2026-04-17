import 'package:geneser/src/services/registry_service.dart';
import 'package:test/test.dart';

void main() {
  group('RegistryService.parseYaml', () {
    test('parses a minimal valid registry', () {
      const yaml = '''
version: 1
templates:
  - id: t1
    name: Template One
    description: desc
    author: "@me"
    compatible_features:
      - f1

features:
  - id: f1
    name: Feature One
    description: desc
''';
      final registry = RegistryService.parseYaml(yaml);
      expect(registry.templates, hasLength(1));
      expect(registry.templates.first.id, 't1');
      expect(registry.templates.first.compatibleFeatures, <String>['f1']);
      expect(registry.features, hasLength(1));
      expect(registry.features.first.id, 'f1');
    });

    test('handles missing sections gracefully', () {
      const yaml = 'version: 1';
      final registry = RegistryService.parseYaml(yaml);
      expect(registry.templates, isEmpty);
      expect(registry.features, isEmpty);
    });

    test('parses feature conflicts and integration', () {
      const yaml = '''
features:
  - id: f1
    name: F1
    description: 'desc'
    requires_integration: int1
    conflicts_with:
      - f2
''';
      final registry = RegistryService.parseYaml(yaml);
      final feature = registry.features.first;
      expect(feature.requiresIntegration, 'int1');
      expect(feature.conflictsWith, contains('f2'));
    });

    test('throws FormatException on non-map root', () {
      expect(
        () => RegistryService.parseYaml('- list\n- items'),
        throwsFormatException,
      );
    });

    test('throws FormatException when a required field is missing', () {
      const yaml = '''
templates:
  - name: Missing id
    description: desc
    author: "@me"
''';
      expect(
        () => RegistryService.parseYaml(yaml),
        throwsFormatException,
      );
    });
  });
}
