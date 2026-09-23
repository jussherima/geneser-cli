import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_repository.g.dart';

class HomeRepository {
  Ref ref;
  HomeRepository(this.ref);
  Future<List<String>> fetch() async => [];
}

@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) => HomeRepository(ref);
