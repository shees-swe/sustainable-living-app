import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import '../domain/waste_category.dart';

class WasteLogRepository {
  WasteLogRepository({required this.database, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase database;
  final DateTime Function() _clock;

  Stream<List<WasteLogEntry>> watchEntries() =>
      (database.select(database.wasteLogEntries)..orderBy([
            (entry) => OrderingTerm.desc(entry.wasteDate),
            (entry) => OrderingTerm.desc(entry.createdAt),
            (entry) => OrderingTerm.desc(entry.entryId),
          ]))
          .watch();

  Future<List<WasteLogEntry>> readEntries() =>
      (database.select(database.wasteLogEntries)..orderBy([
            (entry) => OrderingTerm.desc(entry.wasteDate),
            (entry) => OrderingTerm.desc(entry.createdAt),
            (entry) => OrderingTerm.desc(entry.entryId),
          ]))
          .get();

  Future<void> addEntry({
    required DateTime date,
    required WasteCategory category,
    required double amountKg,
  }) async {
    if (!amountKg.isFinite || amountKg <= 0) {
      throw ArgumentError.value(
        amountKg,
        'amountKg',
        'Must be finite and greater than zero.',
      );
    }

    await database
        .into(database.wasteLogEntries)
        .insert(
          WasteLogEntriesCompanion.insert(
            entryId: _newEntryId(),
            wasteDate: DateTime(date.year, date.month, date.day),
            createdAt: _clock().toUtc(),
            category: category.value,
            amountKg: amountKg,
          ),
        );
  }

  Future<void> deleteEntry(String entryId) async {
    await (database.delete(
      database.wasteLogEntries,
    )..where((entry) => entry.entryId.equals(entryId))).go();
  }

  String _newEntryId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
