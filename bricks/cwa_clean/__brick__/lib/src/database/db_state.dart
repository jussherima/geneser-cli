{{#with_drift}}import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:{{project_name}}/src/database/app_database.dart';
part 'db_state.g.dart';

@Riverpod(keepAlive: true)
AppDatabase db(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}{{/with_drift}}{{^with_drift}}// Drift disabled{{/with_drift}}
