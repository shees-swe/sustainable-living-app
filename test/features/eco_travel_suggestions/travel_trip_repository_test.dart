import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/eco_travel_suggestions/data/travel_trip_repository.dart';

void main() {
  late AppDatabase database;
  late TravelTripRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TravelTripRepository(
      database: database,
      clock: () => DateTime.utc(2026, 11, 12),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('orders dated trips soonest first and undated trips last', () async {
    await repository.addTrip(
      title: 'Later',
      destination: 'Bath',
      transportMode: 'Train',
      date: DateTime(2026, 12, 1),
    );
    await repository.addTrip(
      title: 'Undated',
      destination: 'York',
      transportMode: 'Walking or cycling',
    );
    await repository.addTrip(
      title: 'Sooner',
      destination: 'Leeds',
      transportMode: 'Bus or coach',
      date: DateTime(2026, 11, 20),
    );

    expect((await repository.readTrips()).map((trip) => trip.title), [
      'Sooner',
      'Later',
      'Undated',
    ]);
  });

  test('rejects trips without a title or destination', () async {
    await expectLater(
      repository.addTrip(
        title: ' ',
        destination: 'York',
        transportMode: 'Train',
      ),
      throwsArgumentError,
    );
    await expectLater(
      repository.addTrip(
        title: 'Weekend',
        destination: ' ',
        transportMode: 'Train',
      ),
      throwsArgumentError,
    );
    expect(await repository.readTrips(), isEmpty);
  });

  test('trip survives closing and reopening the local database', () async {
    final directory = await Directory.systemTemp.createTemp('travel-trip-db-');
    final path = p.join(directory.path, 'travel.sqlite');
    final firstDatabase = AppDatabase.forTesting(NativeDatabase(File(path)));
    await TravelTripRepository(database: firstDatabase).addTrip(
      title: 'Weekend by train',
      destination: 'York',
      transportMode: 'Train',
      date: DateTime(2026, 12, 4),
      notes: 'Pack light.',
    );
    await firstDatabase.close();

    final reopenedDatabase = AppDatabase.forTesting(NativeDatabase(File(path)));
    try {
      final trips = await TravelTripRepository(database: reopenedDatabase)
          .readTrips();
      expect(trips, hasLength(1));
      expect(trips.single.title, 'Weekend by train');
      expect(trips.single.destination, 'York');
      expect(trips.single.transportMode, 'Train');
      expect(trips.single.tripDate, DateTime(2026, 12, 4));
      expect(trips.single.notes, 'Pack light.');
    } finally {
      await reopenedDatabase.close();
      await directory.delete(recursive: true);
    }
  });
}
