{{#with_drift}}import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:{{project_name}}/src/database/tables/products.dart';
part 'app_database.g.dart';

@DriftDatabase(tables: [Products])
class AppDatabase extends _\$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _open());
  @override
  int get schemaVersion => 1;
  static QueryExecutor _open() => driftDatabase(name: 'kandra.db', native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory));
}{{/with_drift}}{{^with_drift}}// Drift disabled{{/with_drift}}
