import 'footprint_estimate.dart';

class FootprintCalculator {
  const FootprintCalculator();

  EstimateResult calculate({
    required FootprintAnswers answers,
    required List<EmissionFactor> factors,
  }) {
    _validateAnswers(answers);
    final missingActivityIds = answers.activities
        .where((activity) => activity.amount == null)
        .map((activity) => activity.activityId)
        .toList(growable: false);

    if (missingActivityIds.isNotEmpty) {
      return IncompleteEstimate(
        questionnaireVersion: answers.questionnaireVersion,
        periodYear: answers.periodYear,
        assumptions: const [],
        missingActivityIds: missingActivityIds,
      );
    }

    final usedFactors = <EmissionFactor>[];
    final categoryTotals = <String, double>{};
    var total = 0.0;
    String? numeratorUnit;
    for (final activity in answers.activities) {
      final matchingFactors = factors
          .where((factor) => factor.activityId == activity.activityId)
          .toList(growable: false);
      if (matchingFactors.length != 1) {
        throw UnavailableEstimateFactor(
          matchingFactors.isEmpty
              ? 'No factor is available for ${activity.activityId}.'
              : 'Multiple factors are available for ${activity.activityId}.',
        );
      }

      final factor = matchingFactors.single;
      _validateFactor(factor, activity.unit);
      if (numeratorUnit != null && numeratorUnit != factor.numeratorUnit) {
        throw const UnavailableEstimateFactor(
          'Factors with different greenhouse-gas units cannot be combined.',
        );
      }
      numeratorUnit = factor.numeratorUnit;
      final amount = activity.amount!;
      final contribution = amount * factor.value;
      total += contribution;
      categoryTotals.update(
        factor.category,
        (value) => value + contribution,
        ifAbsent: () => contribution,
      );
      usedFactors.add(factor);
    }

    if (!total.isFinite || total < 0) {
      throw const InvalidEstimateInput(
        'The calculated annual emissions amount is not finite and nonnegative.',
      );
    }

    return CompleteEstimate(
      questionnaireVersion: answers.questionnaireVersion,
      periodYear: answers.periodYear,
      assumptions: const ['annualizedPerPerson'],
      value: total,
      unit: '$numeratorUnit/year',
      factorsUsed: List.unmodifiable(usedFactors),
      categoryTotals: List.unmodifiable([
        for (final entry in categoryTotals.entries)
          EstimateCategoryTotal(category: entry.key, value: entry.value),
      ]),
      displayValue: total.toStringAsFixed(2),
    );
  }

  void _validateAnswers(FootprintAnswers answers) {
    if (answers.questionnaireVersion.trim().isEmpty ||
        answers.periodYear < 1900) {
      throw const InvalidEstimateInput(
        'Questionnaire version and estimate year are required.',
      );
    }
    if (answers.activities.isEmpty) {
      throw const InvalidEstimateInput('At least one activity is required.');
    }

    final seenActivityIds = <String>{};
    for (final activity in answers.activities) {
      if (activity.activityId.trim().isEmpty ||
          activity.unit.trim().isEmpty ||
          !seenActivityIds.add(activity.activityId)) {
        throw const InvalidEstimateInput(
          'Activity identifiers and units must be present and unique.',
        );
      }
      final amount = activity.amount;
      if (amount != null && (!amount.isFinite || amount < 0)) {
        throw InvalidEstimateInput(
          'Activity amount for ${activity.activityId} must be finite and nonnegative.',
        );
      }
    }
  }

  void _validateFactor(EmissionFactor factor, String activityUnit) {
    const supportedActivityUnits = {'kWh', 'km'};
    if (!factor.value.isFinite ||
        factor.value < 0 ||
        factor.factorId.trim().isEmpty ||
        factor.category.trim().isEmpty ||
        factor.activityId.trim().isEmpty ||
        !const {'kg CO2', 'kg CO2e'}.contains(factor.numeratorUnit) ||
        !supportedActivityUnits.contains(factor.denominatorUnit) ||
        factor.denominatorUnit != activityUnit ||
        factor.source.sourceId.trim().isEmpty ||
        factor.source.title.trim().isEmpty ||
        factor.source.publicationYear < 1900 ||
        factor.validFrom.trim().isEmpty ||
        factor.methodology.trim().isEmpty) {
      throw UnavailableEstimateFactor(
        'Factor ${factor.factorId} is invalid or incompatible with the activity.',
      );
    }
  }
}
