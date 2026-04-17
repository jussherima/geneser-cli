import 'package:geneser/src/models/registry.dart';
import 'package:test/test.dart';

void main() {
  group('Registry.builtin', () {
    test('has at least one template', () {
      expect(Registry.builtin.templates, isNotEmpty);
    });

    test('has at least two features', () {
      expect(Registry.builtin.features.length, greaterThanOrEqualTo(2));
    });

    test('every feature referenced by a template exists', () {
      final Set<String> featureIds =
          Registry.builtin.features.map((f) => f.id).toSet();
      for (final template in Registry.builtin.templates) {
        for (final featureId in template.compatibleFeatures) {
          expect(
            featureIds,
            contains(featureId),
            reason:
                'Template "${template.id}" references unknown feature "$featureId".',
          );
        }
      }
    });

    test('templateById and featureById find entries', () {
      final firstTemplate = Registry.builtin.templates.first;
      expect(
        Registry.builtin.templateById(firstTemplate.id)?.id,
        firstTemplate.id,
      );
      expect(Registry.builtin.templateById('does_not_exist'), isNull);

      final firstFeature = Registry.builtin.features.first;
      expect(
        Registry.builtin.featureById(firstFeature.id)?.id,
        firstFeature.id,
      );
      expect(Registry.builtin.featureById('does_not_exist'), isNull);
    });
  });
}
