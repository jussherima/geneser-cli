import 'feature.dart';
import 'template.dart';

class Registry {
  const Registry({required this.templates, required this.features});

  final List<Template> templates;
  final List<Feature> features;

  Template? templateById(String id) {
    for (final template in templates) {
      if (template.id == id) return template;
    }
    return null;
  }

  Feature? featureById(String id) {
    for (final feature in features) {
      if (feature.id == id) return feature;
    }
    return null;
  }

  /// Hard-coded registry used until the remote registry is wired up (Phase 2).
  static const Registry builtin = Registry(
    templates: <Template>[
      Template(
        id: 'starter_riverpod_gorouter',
        name: 'Starter Riverpod + go_router',
        description:
            'A pragmatic starter: Riverpod for state, go_router for navigation, clear folder layout.',
        author: '@geneser',
        compatibleFeatures: <String>[
          'auth_firebase',
          'theming_dark_light',
        ],
      ),
    ],
    features: <Feature>[
      Feature(
        id: 'auth_firebase',
        name: 'Firebase Authentication',
        description: 'Email and Google sign-in via Firebase Auth.',
        requiresIntegration: 'firebase_setup',
        conflictsWith: <String>['auth_supabase'],
      ),
      Feature(
        id: 'theming_dark_light',
        name: 'Dark / Light theming',
        description: 'Light and dark theme with persisted user preference.',
      ),
    ],
  );
}
