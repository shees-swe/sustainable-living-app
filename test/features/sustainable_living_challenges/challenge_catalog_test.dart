import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChallengeCatalog catalog;

  setUpAll(() async {
    catalog = await ChallengeCatalog.loadBundled();
  });

  test('bundled catalog contains exactly the ten specified challenges', () {
    expect(
      catalog.challenges
          .map(
            (challenge) => [
              challenge.title,
              challenge.theme,
              challenge.days,
              challenge.description,
            ],
          )
          .toList(),
      [
        [
          'Plastic-Free Week',
          'Plastic',
          7,
          'Refuse single-use plastic all week: carry your own bag, bottle, and containers, and say no to plastic cutlery and straws.',
        ],
        [
          'Five-Minute Showers',
          'Water',
          7,
          'Keep every shower to five minutes or less for a full week. A timer or one song is your guide.',
        ],
        [
          'Meat-Free Week',
          'Food',
          7,
          'Eat plant-based for a week. Lentils, beans, and seasonal vegetables cover protein without meat.',
        ],
        [
          'Zero Food Waste',
          'Food',
          7,
          'Plan meals before shopping, use leftovers first, and compost scraps — nothing edible goes in the bin for a week.',
        ],
        [
          'Lights-Out Habit',
          'Energy',
          14,
          'Switch off lights and fans in empty rooms, and unplug chargers and idle devices, every day for two weeks.',
        ],
        [
          'Sort Your Waste',
          'Waste',
          14,
          'Separate recyclables — plastic, paper, metal, glass — from general waste every day for two weeks.',
        ],
        [
          'Cold-Wash Laundry',
          'Energy',
          14,
          'Wash clothes in cold water and line-dry them instead of using a dryer, for two weeks.',
        ],
        [
          'Walk & Cycle Short Trips',
          'Transport',
          21,
          'Make every trip under two kilometres on foot or by bicycle for three weeks.',
        ],
        [
          'Grow a Plant',
          'Green',
          30,
          'Plant a seed or a small sapling and care for it daily for a month — water, light, and a minute of attention.',
        ],
        [
          'Carry a Reusable Kit',
          'Plastic',
          30,
          'Keep a kit with you every day for a month — bottle, bag, cutlery, container — so disposables are never needed.',
        ],
      ],
    );
    expect(catalog.challenges, hasLength(10));
  });
}
