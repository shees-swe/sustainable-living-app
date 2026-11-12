import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/features/eco_travel_suggestions/data/travel_guide_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TravelGuideCatalog catalog;

  setUpAll(() async {
    catalog = await TravelGuideCatalog.loadBundled();
  });

  test('bundled guide contains the exact seven modes and six tips', () {
    expect(catalog.modes.map((mode) => [mode.mode, mode.guidance]).toList(), [
      [
        'Walking or cycling',
        'The lowest-impact way to travel — no fuel, no emissions, and you see the place properly.',
      ],
      [
        'Train',
        'One of the lowest-impact motorised options, especially on electric lines.',
      ],
      [
        'Bus or coach',
        'Sharing the ride spreads the fuel across every passenger.',
      ],
      [
        'Car, shared',
        'A full car is far better than an empty one — fill every seat you can.',
      ],
      [
        'Car, solo',
        'Convenient, but the highest-impact road option per person; combine several stops into one journey.',
      ],
      [
        'Ferry',
        'A reasonable option for coastal and island routes; slower usually means gentler.',
      ],
      [
        'Plane',
        'The highest-impact choice for most trips; if you fly, fewer and longer trips help.',
      ],
    ]);
    expect(catalog.tips.map((tip) => [tip.title, tip.text]).toList(), [
      [
        'Pick the highest rung you can',
        'For most trips the order runs: walking and cycling first, then trains and buses, then a shared car, then a solo car, with flying last. Choose the highest rung your trip allows.',
      ],
      [
        'Prefer trains for medium distances',
        'Where a railway exists, trains usually beat driving alone and flying on both comfort and impact — and the journey becomes part of the trip.',
      ],
      [
        'Pack light',
        'Every extra kilo is carried by your transport the whole way; a lighter bag is a small saving multiplied by every kilometre.',
      ],
      [
        'Fly less, stay longer',
        'One two-week stay instead of two weekend flights halves the flying for the same days away.',
      ],
      [
        'Choose stays that prove it',
        'Look for accommodation with third-party certification — the Brand Directory module explains the labels — or locally owned guesthouses that keep money in the community.',
      ],
      [
        'Leave places as you found them',
        'Carry a reusable bottle and bag while travelling, refuse single-use plastics, and stick to marked paths in natural areas.',
      ],
    ]);
    expect(catalog.modes, hasLength(7));
    expect(catalog.tips, hasLength(6));
  });
}
