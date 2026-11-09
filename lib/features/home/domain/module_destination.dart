enum NavigationGroup { homePrimary, secondary }

enum DestinationAvailability { foundationStub }

class ModuleDestination {
  const ModuleDestination({
    required this.id,
    required this.path,
    required this.titleKey,
    required this.navigationGroup,
    required this.availability,
  });

  final String id;
  final String path;
  final String titleKey;
  final NavigationGroup navigationGroup;
  final DestinationAvailability availability;

  static const String aboutUsPath = '/about';
  static const String aboutUsTitleKey = 'aboutUs';

  static const List<ModuleDestination> modules = [
    ModuleDestination(
      id: 'carbonFootprintTracker',
      path: '/carbon-footprint',
      titleKey: 'carbonFootprintTracker',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
    ModuleDestination(
      id: 'ecoFriendlyProductSuggestions',
      path: '/product-suggestions',
      titleKey: 'ecoFriendlyProductSuggestions',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
    ModuleDestination(
      id: 'sustainableLivingChallenges',
      path: '/challenges',
      titleKey: 'sustainableLivingChallenges',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
    ModuleDestination(
      id: 'certificationsGuide',
      path: '/certifications',
      titleKey: 'certificationsGuide',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
    ModuleDestination(
      id: 'wasteReductionTracker',
      path: '/waste-tracker',
      titleKey: 'wasteReductionTracker',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
    ModuleDestination(
      id: 'recipesMealPlanning',
      path: '/recipes',
      titleKey: 'recipesMealPlanning',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
    ModuleDestination(
      id: 'energyConservationTips',
      path: '/energy-tips',
      titleKey: 'energyConservationTips',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
    ModuleDestination(
      id: 'ecoTravelSuggestions',
      path: '/eco-travel',
      titleKey: 'ecoTravelSuggestions',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
    ModuleDestination(
      id: 'communityJournal',
      path: '/community-journal',
      titleKey: 'communityJournal',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
    ModuleDestination(
      id: 'progressDashboard',
      path: '/progress',
      titleKey: 'progressDashboard',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
    ModuleDestination(
      id: 'educationalContent',
      path: '/education',
      titleKey: 'educationalContent',
      navigationGroup: NavigationGroup.homePrimary,
      availability: DestinationAvailability.foundationStub,
    ),
  ];
}
