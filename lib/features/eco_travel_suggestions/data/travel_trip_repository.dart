import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';

class TravelTripRepository {
  TravelTripRepository({required this.database, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase database;
  final DateTime Function() _clock;

  Stream<List<PlannedTrip>> watchTrips() => _tripsQuery().watch();

  Future<List<PlannedTrip>> readTrips() => _tripsQuery().get();

  Future<void> addTrip({
    required String title,
    required String destination,
    required String transportMode,
    DateTime? date,
    String? notes,
  }) async {
    final trip = _validatedFields(
      title: title,
      destination: destination,
      transportMode: transportMode,
      date: date,
      notes: notes,
    );
    await database
        .into(database.plannedTrips)
        .insert(
          PlannedTripsCompanion.insert(
            tripId: _newTripId(),
            title: trip.title,
            destination: trip.destination,
            transportMode: trip.transportMode,
            tripDate: Value(trip.date),
            notes: Value(trip.notes),
            createdAt: _clock().toUtc(),
          ),
        );
  }

  Future<void> editTrip({
    required String tripId,
    required String title,
    required String destination,
    required String transportMode,
    DateTime? date,
    String? notes,
  }) async {
    final trip = _validatedFields(
      title: title,
      destination: destination,
      transportMode: transportMode,
      date: date,
      notes: notes,
    );
    final updated =
        await (database.update(
          database.plannedTrips,
        )..where((row) => row.tripId.equals(tripId))).write(
          PlannedTripsCompanion(
            title: Value(trip.title),
            destination: Value(trip.destination),
            transportMode: Value(trip.transportMode),
            tripDate: Value(trip.date),
            notes: Value(trip.notes),
          ),
        );
    if (updated == 0) throw StateError('The planned trip no longer exists.');
  }

  Future<void> deleteTrip(String tripId) async {
    await (database.delete(
      database.plannedTrips,
    )..where((row) => row.tripId.equals(tripId))).go();
  }

  SimpleSelectStatement<$PlannedTripsTable, PlannedTrip> _tripsQuery() =>
      database.select(database.plannedTrips)..orderBy([
        (trip) => OrderingTerm.asc(trip.tripDate.isNull()),
        (trip) => OrderingTerm.asc(trip.tripDate),
        (trip) => OrderingTerm.desc(trip.createdAt),
        (trip) => OrderingTerm.asc(trip.tripId),
      ]);

  _ValidatedTrip _validatedFields({
    required String title,
    required String destination,
    required String transportMode,
    required DateTime? date,
    required String? notes,
  }) {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Must not be empty.');
    }
    final cleanDestination = destination.trim();
    if (cleanDestination.isEmpty) {
      throw ArgumentError.value(
        destination,
        'destination',
        'Must not be empty.',
      );
    }
    final cleanMode = transportMode.trim();
    if (cleanMode.isEmpty) {
      throw ArgumentError.value(
        transportMode,
        'transportMode',
        'Must not be empty.',
      );
    }
    final cleanNotes = notes?.trim();
    return _ValidatedTrip(
      title: cleanTitle,
      destination: cleanDestination,
      transportMode: cleanMode,
      date: date == null ? null : DateTime(date.year, date.month, date.day),
      notes: cleanNotes == null || cleanNotes.isEmpty ? null : cleanNotes,
    );
  }

  String _newTripId() {
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

class _ValidatedTrip {
  const _ValidatedTrip({
    required this.title,
    required this.destination,
    required this.transportMode,
    required this.date,
    required this.notes,
  });

  final String title;
  final String destination;
  final String transportMode;
  final DateTime? date;
  final String? notes;
}
