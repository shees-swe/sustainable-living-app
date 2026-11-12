import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/data/waste_log_repository.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/domain/waste_category.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/domain/waste_month_summary.dart';

void main() {
  late AppDatabase database;
  late WasteLogRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = WasteLogRepository(
      database: database,
      clock: () => DateTime.utc(2026, 11, 12),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('uses the exact six waste categories', () {
    expect(WasteCategory.values.map((category) => category.value), [
      'Plastic',
      'Paper & cardboard',
      'Glass',
      'Metal',
      'Organic',
      'Other',
    ]);
  });

  test(
    'orders entries newest first and reconciles monthly category totals',
    () async {
      await repository.addEntry(
        date: DateTime(2026, 11, 5),
        category: WasteCategory.plastic,
        amountKg: 1.25,
      );
      await repository.addEntry(
        date: DateTime(2026, 11, 6),
        category: WasteCategory.paperAndCardboard,
        amountKg: 2.5,
      );
      await repository.addEntry(
        date: DateTime(2026, 11, 7),
        category: WasteCategory.plastic,
        amountKg: 0.75,
      );
      await repository.addEntry(
        date: DateTime(2026, 10, 31),
        category: WasteCategory.glass,
        amountKg: 10,
      );

      final entries = await repository.readEntries();
      expect(entries.map((entry) => entry.wasteDate.day), [7, 6, 5, 31]);

      final summary = WasteMonthSummary.fromEntries(
        entries: entries,
        month: DateTime(2026, 11),
      );
      expect(summary.totalKgCents, 450);
      expect(
        summary.categories.map(
          (total) => [total.category.value, total.kgCents],
        ),
        [
          ['Plastic', 200],
          ['Paper & cardboard', 250],
        ],
      );
      expect(
        summary.categories.fold<int>(0, (sum, total) => sum + total.kgCents),
        summary.totalKgCents,
      );
    },
  );

  test('rejects zero, negative, and non-finite amounts', () async {
    for (final amount in [0.0, -0.5, double.infinity, double.nan]) {
      await expectLater(
        repository.addEntry(
          date: DateTime(2026, 11, 12),
          category: WasteCategory.other,
          amountKg: amount,
        ),
        throwsArgumentError,
      );
    }
    expect(await repository.readEntries(), isEmpty);
  });

  test(
    'rounds category figures to cents and reconciles them to the month',
    () async {
      for (final category in [
        WasteCategory.plastic,
        WasteCategory.paperAndCardboard,
        WasteCategory.glass,
        WasteCategory.metal,
        WasteCategory.organic,
        WasteCategory.other,
      ]) {
        await repository.addEntry(
          date: DateTime(2026, 11, 12),
          category: category,
          amountKg: 0.005,
        );
      }

      final summary = WasteMonthSummary.fromEntries(
        entries: await repository.readEntries(),
        month: DateTime(2026, 11),
      );
      expect(summary.totalKgCents, 3);
      expect(summary.categories.map((total) => total.kgCents), [
        0,
        0,
        0,
        1,
        1,
        1,
      ]);
      expect(summary.categories.every((total) => total.kgCents >= 0), isTrue);
      expect(
        summary.categories.fold<int>(0, (sum, total) => sum + total.kgCents),
        summary.totalKgCents,
      );
    },
  );

  test('entry survives closing and reopening the local database', () async {
    final directory = await Directory.systemTemp.createTemp('waste-log-db-');
    final path = p.join(directory.path, 'waste.sqlite');
    final firstDatabase = AppDatabase.forTesting(NativeDatabase(File(path)));
    await WasteLogRepository(database: firstDatabase).addEntry(
      date: DateTime(2026, 11, 12),
      category: WasteCategory.paperAndCardboard,
      amountKg: 3.75,
    );
    await firstDatabase.close();

    final reopenedDatabase = AppDatabase.forTesting(NativeDatabase(File(path)));
    try {
      final entries = await WasteLogRepository(database: reopenedDatabase)
          .readEntries();
      expect(entries, hasLength(1));
      expect(entries.single.category, 'Paper & cardboard');
      expect(entries.single.amountKg, 3.75);
    } finally {
      await reopenedDatabase.close();
      await directory.delete(recursive: true);
    }
  });
}
