class CanonicalFactorDefinition {
  const CanonicalFactorDefinition({
    required this.factorId,
    required this.category,
    required this.activityId,
    required this.numeratorUnit,
    required this.denominatorUnit,
  });

  final String factorId;
  final String category;
  final String activityId;
  final String numeratorUnit;
  final String denominatorUnit;
}

class CanonicalEmissionFactorCatalog {
  const CanonicalEmissionFactorCatalog({
    this.version = currentVersion,
    this.definitions = canonicalDefinitions,
  });

  static const String currentVersion = '1.0.0';

  static const List<CanonicalFactorDefinition> canonicalDefinitions = [
    CanonicalFactorDefinition(
      factorId: 'electricity-grid',
      category: 'electricity',
      activityId: 'electricity',
      numeratorUnit: 'kg CO2',
      denominatorUnit: 'kWh',
    ),
  ];

  final String version;
  final List<CanonicalFactorDefinition> definitions;

  CanonicalFactorDefinition? definitionFor(String factorId) {
    for (final definition in definitions) {
      if (definition.factorId == factorId) return definition;
    }
    return null;
  }
}
