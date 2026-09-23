{{#with_auth}}import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'secured_storage.g.dart';

@Riverpod(keepAlive: true)
SecuredStorage securedStorage(Ref ref) => SecuredStorage();

class SecuredStorage {
  final _s = const FlutterSecureStorage();
  Future<String?> read(String k) => _s.read(key: k);
  Future<void> write(String k, String v) => _s.write(key: k, value: v);
  Future<void> delete(String k) => _s.delete(key: k);
}{{/with_auth}}{{^with_auth}}// auth disabled, no secure storage{{/with_auth}}