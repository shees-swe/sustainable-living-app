import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/features/energy_conservation_tips/data/energy_tip_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EnergyTipCatalog catalog;

  setUpAll(() async {
    catalog = await EnergyTipCatalog.loadBundled();
  });

  test('bundled catalog contains the exact eleven supplied tips', () {
    expect(
      catalog.tips.map((tip) => [tip.title, tip.category, tip.text]).toList(),
      [
        [
          'Use fans before air conditioning',
          'Heating & cooling',
          'Fans use a fraction of the energy of air conditioning; often, moving air is all a room needs.',
        ],
        [
          'Seal gaps around doors and windows',
          'Heating & cooling',
          'Draughts let heated or cooled air escape; simple seals and door sweeps keep the air you paid to condition inside.',
        ],
        [
          'Work with the sun',
          'Heating & cooling',
          'Close curtains on sun-facing windows in the hot part of the day to keep rooms cooler; in cold weather, open them and let the sun warm the room.',
        ],
        [
          'Switch to LED bulbs',
          'Lighting',
          'LEDs use far less energy than incandescent bulbs and last much longer, so each switch saves twice — power and replacements.',
        ],
        [
          'Use daylight first',
          'Lighting',
          'Arrange work and reading near windows, and switch lights off in empty rooms; the cheapest light is the one already coming through the glass.',
        ],
        [
          'Kill standby power',
          'Appliances',
          'Many devices draw power while switched "off". A switchable power strip turns a whole group off at once — chargers, TVs, and consoles included.',
        ],
        [
          'Run full loads',
          'Appliances',
          'Washing machines and dishwashers use nearly the same energy partly loaded; full loads mean fewer cycles for the same work.',
        ],
        [
          'Set the fridge right',
          'Appliances',
          'Keep the fridge near 4 °C and the freezer near −18 °C; colder settings waste energy without keeping food any safer. A fridge works best neither empty nor overpacked.',
        ],
        [
          'Shorter, cooler showers',
          'Water',
          'Heating water takes real energy; shorter showers at a lower temperature cut water and energy use together.',
        ],
        [
          'Consider rooftop solar',
          'Renewables',
          "Solar panels turn a roof into a small power station; even a small system can cover daytime basics like lights, fans, and charging. Start by checking how much sun your roof gets and how much power you use in the daytime.",
        ],
        [
          'Take one small solar step',
          'Renewables',
          'If a full system is too big a step, solar garden lights, a solar power bank, or a solar water heater each cut one slice of grid use.',
        ],
      ],
    );
    expect(catalog.tips, hasLength(11));
    expect(catalog.categories, [
      'Heating & cooling',
      'Lighting',
      'Appliances',
      'Water',
      'Renewables',
    ]);
  });

  test('search covers titles and text and combines with category', () {
    expect(
      catalog
          .filter(query: 'Use fans before air conditioning')
          .map((tip) => tip.title),
      ['Use fans before air conditioning'],
    );
    expect(catalog.filter(query: 'door sweeps').map((tip) => tip.title), [
      'Seal gaps around doors and windows',
    ]);
    expect(catalog.filter(category: 'Lighting').map((tip) => tip.title), [
      'Switch to LED bulbs',
      'Use daylight first',
    ]);
    expect(
      catalog
          .filter(query: 'power strip', category: 'Appliances')
          .map((tip) => tip.title),
      ['Kill standby power'],
    );
    expect(
      catalog
          .filter(query: 'power strip', category: 'Lighting')
          .map((tip) => tip.title),
      isEmpty,
    );
  });
}
