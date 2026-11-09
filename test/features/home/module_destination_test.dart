import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/features/home/domain/module_destination.dart';

void main() {
  test('registers exactly the required 11 primary module destinations', () {
    expect(
      ModuleDestination.modules.map((destination) => destination.id).toSet(),
      {
        'carbonFootprintTracker',
        'ecoFriendlyProductSuggestions',
        'sustainableLivingChallenges',
        'certificationsGuide',
        'wasteReductionTracker',
        'recipesMealPlanning',
        'energyConservationTips',
        'ecoTravelSuggestions',
        'communityJournal',
        'progressDashboard',
        'educationalContent',
      },
    );
    expect(ModuleDestination.modules, hasLength(11));
    expect(
      ModuleDestination.modules.every(
        (destination) =>
            destination.navigationGroup == NavigationGroup.homePrimary,
      ),
      isTrue,
    );
    expect(
      ModuleDestination.modules.every(
        (destination) =>
            destination.availability == DestinationAvailability.foundationStub,
      ),
      isTrue,
    );
  });

  test('keeps About Us reachable from Home outside the module inventory', () {
    expect(ModuleDestination.aboutUsPath, '/about');
    expect(ModuleDestination.aboutUsTitleKey, 'aboutUs');
  });

  test('provides stable routes and localization keys for every module', () {
    final paths = ModuleDestination.modules
        .map((destination) => destination.path)
        .toSet();
    final titleKeys = ModuleDestination.modules
        .map((destination) => destination.titleKey)
        .toSet();

    expect(paths, hasLength(11));
    expect(titleKeys, hasLength(11));
    expect(paths, isNot(contains('/gallery')));
    expect(paths, isNot(contains('/contact')));
  });
}
