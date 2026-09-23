{{#backend_is_rest}}import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:{{project_name}}/src/config/app_env.dart';
part 'http_client.g.dart';

@Riverpod(keepAlive: true)
HttpClient httpClient(Ref ref) => HttpClient.fromEnv();

class HttpClient with DioMixin implements Dio {
  String? authToken;
  HttpClient({required String baseUrl}) {
    options = BaseOptions(baseUrl: baseUrl);
    httpClientAdapter = HttpClientAdapter();
    interceptors.add(InterceptorsWrapper(onRequest: (o,h){ if(authToken!=null) o.headers['Authorization']='Bearer \$authToken'; return h.next(o); }));
  }
  factory HttpClient.fromEnv() => HttpClient(baseUrl: AppEnv.fromEnv().backendUrl);
}{{/backend_is_rest}}{{^backend_is_rest}}// no rest backend{{/backend_is_rest}}
