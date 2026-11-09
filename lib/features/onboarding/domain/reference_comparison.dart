import 'reference_value.dart';

class ReferenceComparisonService {
  const ReferenceComparisonService();

  ReferenceComparisonResult compare({
    required EstimateComparisonBasis estimate,
    required ReferenceValue reference,
    required Map<String, ReferenceSource> sources,
  }) {
    if (!estimate.value.isFinite ||
        estimate.value < 0 ||
        estimate.unit.trim().isEmpty ||
        estimate.period.trim().isEmpty ||
        estimate.accountingBoundary.trim().isEmpty) {
      return const ReferenceComparisonResult.unavailable(
        reason: 'Estimate comparison basis is invalid.',
      );
    }

    final value = reference.value;
    final reason = reference.reason;
    if (value == null) {
      return ReferenceComparisonResult.unavailable(
        reason: reason ?? 'Reference value is unavailable.',
      );
    }

    final sourceId = reference.sourceId;
    final source = sourceId == null ? null : sources[sourceId];
    if (source == null) {
      return const ReferenceComparisonResult.unavailable(
        reason: 'Reference source is unavailable.',
      );
    }
    if (!value.isFinite || value < 0) {
      return const ReferenceComparisonResult.unavailable(
        reason: 'Reference value is invalid.',
      );
    }
    if (reference.period != estimate.period ||
        reference.unit != estimate.unit ||
        reference.accountingBoundary != estimate.accountingBoundary) {
      return const ReferenceComparisonResult.unavailable(
        reason:
            'Reference period, unit, or accounting boundary is incompatible.',
      );
    }
    if (source.sourceId != sourceId ||
        source.sourceId.trim().isEmpty ||
        source.title.trim().isEmpty ||
        source.publisher.trim().isEmpty ||
        source.publicationYear < 1900 ||
        reference.methodology == null ||
        reference.methodology!.trim().isEmpty) {
      return const ReferenceComparisonResult.unavailable(
        reason: 'Reference source metadata is incomplete.',
      );
    }

    return ReferenceComparisonResult.available(
      value: value,
      source: source,
      methodology: reference.methodology ?? '',
      period: reference.period!,
      unit: reference.unit!,
      accountingBoundary: reference.accountingBoundary!,
    );
  }
}
