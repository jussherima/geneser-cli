import 'package:freezed_annotation/freezed_annotation.dart';
part 'app_env.freezed.dart';
part 'app_env.g.dart';

@freezed
sealed class AppEnv with _\$AppEnv {
  const factory AppEnv.dev({required String name, required String backendUrl, String? supportEmail}) = DevEnv;
  const factory AppEnv.prod({required String name, required String backendUrl, String? sentryDsn, String? supportEmail, String? appStoreId}) = ProdEnv;
  const factory AppEnv.local({required String name, required String backendUrl}) = LocalEnv;
  const factory AppEnv.stg({required String name, required String backendUrl}) = StgEnv;
  const AppEnv._();
  factory AppEnv.fromEnv() {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    const backend = String.fromEnvironment('BACKEND_URL', defaultValue: 'https://api.example.com');
    switch (env) {
      case 'dev': return const AppEnv.dev(name: 'dev', backendUrl: backend);
      case 'prod': return AppEnv.prod(name: 'prod', backendUrl: backend, sentryDsn: const String.fromEnvironment('SENTRY_DSN'));
      case 'local': return const AppEnv.local(name: 'local', backendUrl: backend);
      case 'stg': return const AppEnv.stg(name: 'stg', backendUrl: backend);
      default: throw Exception('Unknown ENV ' + env);
    }
  }
  String get backendUrl => map(dev: (e)=>e.backendUrl, prod: (e)=>e.backendUrl, local: (e)=>e.backendUrl, stg: (e)=>e.backendUrl);
  String get name => map(dev: (e)=>e.name, prod: (e)=>e.name, local: (e)=>e.name, stg: (e)=>e.name);
}
