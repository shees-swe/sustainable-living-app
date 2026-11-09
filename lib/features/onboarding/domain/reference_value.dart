class EstimateComparisonBasis {
  const EstimateComparisonBasis({
    required this.value,
    required this.unit,
    required this.period,
    required this.accountingBoundary,
  });

  final double value;
  final String unit;
  final String period;
  final String accountingBoundary;
}

class ReferenceSource {
  const ReferenceSource({
    required this.sourceId,
    required this.title,
    required this.publisher,
    required this.publicationYear,
    this.url,
    this.reportVersion,
  });

  final String sourceId;
  final String title;
  final String publisher;
  final int publicationYear;
  final String? url;
  final String? reportVersion;
}

class ReferenceValue {
  const ReferenceValue({
    required this.referenceId,
    required this.value,
    required this.unit,
    required this.period,
    required this.sourceId,
    required this.methodology,
    required this.accountingBoundary,
    this.uncertainty,
  }) : reason = null;

  const ReferenceValue.unavailable({
    required this.referenceId,
    required this.reason,
  }) : value = null,
       unit = null,
       period = null,
       sourceId = null,
       methodology = null,
       accountingBoundary = null,
       uncertainty = null;

  final String referenceId;
  final double? value;
  final String? unit;
  final String? period;
  final String? sourceId;
  final String? methodology;
  final String? accountingBoundary;
  final String? uncertainty;
  final String? reason;
}

enum ReferenceComparisonStatus { available, unavailable }

class ReferenceComparisonResult {
  const ReferenceComparisonResult.available({
    required this.value,
    required this.source,
    required this.methodology,
    required this.period,
    required this.unit,
    required this.accountingBoundary,
  }) : status = ReferenceComparisonStatus.available,
       reason = null;

  const ReferenceComparisonResult.unavailable({required this.reason})
    : status = ReferenceComparisonStatus.unavailable,
      value = null,
      source = null,
      methodology = null,
      period = null,
      unit = null,
      accountingBoundary = null;

  final ReferenceComparisonStatus status;
  final double? value;
  final ReferenceSource? source;
  final String? methodology;
  final String? period;
  final String? unit;
  final String? accountingBoundary;
  final String? reason;
}
