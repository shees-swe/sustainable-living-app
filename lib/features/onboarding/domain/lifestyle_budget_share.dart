double? lifestyleBudgetShare({
  required String referenceId,
  required double referenceValue,
  required String referenceUnit,
  required String referencePeriod,
  required int targetYear,
  required double estimateValue,
  required String estimateUnit,
  required Iterable<String> assumptions,
}) {
  if (referenceId != 'temperature-budget-1-5c' ||
      referenceUnit != 't CO2e/person/year' ||
      referencePeriod != targetYear.toString() ||
      estimateUnit != 'kg CO2e/year' ||
      !assumptions.contains('annualizedPerPerson') ||
      referenceValue <= 0) {
    return null;
  }
  return estimateValue / (referenceValue * 1000);
}
