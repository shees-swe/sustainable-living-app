enum EstimateCompletionState { complete, incomplete }

class FootprintAnswers {
  const FootprintAnswers({
    required this.questionnaireVersion,
    required this.periodYear,
    required this.activities,
    this.regionId,
  });

  final String questionnaireVersion;
  final int periodYear;
  final List<ActivityInput> activities;
  final String? regionId;

  Map<String, Object?> toJson() => {
    'questionnaireVersion': questionnaireVersion,
    'periodYear': periodYear,
    if (regionId != null) 'regionId': regionId,
    'activities': activities.map((activity) => activity.toJson()).toList(),
  };
}

class ActivityInput {
  const ActivityInput({
    required this.activityId,
    required this.amount,
    required this.unit,
  });

  final String activityId;
  final double? amount;
  final String unit;

  Map<String, Object?> toJson() => {
    'activityId': activityId,
    'amount': amount,
    'unit': unit,
  };
}

class FactorSource {
  const FactorSource({
    required this.sourceId,
    required this.title,
    required this.publicationYear,
    this.publisher,
    this.url,
  });

  final String sourceId;
  final String title;
  final int publicationYear;
  final String? publisher;
  final String? url;
}

class EmissionFactor {
  const EmissionFactor({
    required this.factorId,
    required this.category,
    required this.activityId,
    required this.value,
    required this.numeratorUnit,
    required this.denominatorUnit,
    required this.source,
    required this.validFrom,
    required this.methodology,
  });

  final String factorId;
  final String category;
  final String activityId;
  final double value;
  final String numeratorUnit;
  final String denominatorUnit;
  final FactorSource source;
  final String validFrom;
  final String methodology;
}

sealed class EstimateResult {
  const EstimateResult({
    required this.questionnaireVersion,
    required this.periodYear,
    required this.assumptions,
  });

  final String questionnaireVersion;
  final int periodYear;
  final List<String> assumptions;
  EstimateCompletionState get completionState;
}

class CompleteEstimate extends EstimateResult {
  const CompleteEstimate({
    required super.questionnaireVersion,
    required super.periodYear,
    required super.assumptions,
    required this.value,
    required this.unit,
    required this.factorsUsed,
    required this.displayValue,
  });

  final double value;
  final String unit;
  final List<EmissionFactor> factorsUsed;
  final String displayValue;

  @override
  EstimateCompletionState get completionState =>
      EstimateCompletionState.complete;
}

class IncompleteEstimate extends EstimateResult {
  const IncompleteEstimate({
    required super.questionnaireVersion,
    required super.periodYear,
    required super.assumptions,
    required this.missingActivityIds,
  });

  final List<String> missingActivityIds;

  @override
  EstimateCompletionState get completionState =>
      EstimateCompletionState.incomplete;
}

class InvalidEstimateInput implements Exception {
  const InvalidEstimateInput(this.message);

  final String message;

  @override
  String toString() => 'InvalidEstimateInput: $message';
}

class UnavailableEstimateFactor implements Exception {
  const UnavailableEstimateFactor(this.message);

  final String message;

  @override
  String toString() => 'UnavailableEstimateFactor: $message';
}
