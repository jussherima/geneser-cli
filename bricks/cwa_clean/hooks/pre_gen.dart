import 'package:mason/mason.dart';

void run(HookContext context) {
  // Environments array -> booleans
  final envs = (context.vars['environments'] as List?)?.map((e) => e.toString()).toList() ?? [];
  context.vars['with_env_dev'] = envs.contains('dev');
  context.vars['with_env_prod'] = envs.contains('prod');
  context.vars['with_env_local'] = envs.contains('local');
  context.vars['with_env_stg'] = envs.contains('stg');

  // Features array -> booleans
  final feats = (context.vars['features'] as List?)?.map((e) => e.toString()).toList() ?? [];
  context.vars['with_auth'] = feats.contains('auth');
  context.vars['with_feed'] = feats.contains('feed');
  context.vars['with_notifications'] = feats.contains('notifications');
  context.vars['with_profile'] = feats.contains('profile');
  context.vars['with_language_settings'] = feats.contains('language_settings');
  context.vars['with_drift'] = feats.contains('drift');
  context.vars['with_i18n'] = feats.contains('i18n');

  // Backend enum -> booleans
  final backend = context.vars['backend'] as String? ?? 'none';
  context.vars['with_backend'] = backend != 'none';
  context.vars['backend_is_firebase'] = backend == 'firebase';
  context.vars['backend_is_supabase'] = backend == 'supabase';
  context.vars['backend_is_rest'] = backend == 'rest_api';
  // compat: keep backend_provider for old templates if needed
  context.vars['backend_provider'] = backend;
}
