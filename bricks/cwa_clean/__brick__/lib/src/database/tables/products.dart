{{#with_drift}}import 'package:drift/drift.dart';
class Products extends Table { IntColumn get id => integer().autoIncrement()(); TextColumn get name => text()(); RealColumn get price => real()(); IntColumn get stock => integer().withDefault(const Constant(0))(); }{{/with_drift}}{{^with_drift}}// disabled{{/with_drift}}
