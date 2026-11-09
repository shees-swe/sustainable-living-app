import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';

void main() {
  test('creates and validates the initial database schema', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await database.select(database.userPreferences).get();
    expect(database.schemaVersion, 1);

    await database.validateDatabaseSchema();

    final foreignKeyViolations =
        await database.customSelect('PRAGMA foreign_key_check').get();
    expect(foreignKeyViolations, isEmpty);
  });
}
