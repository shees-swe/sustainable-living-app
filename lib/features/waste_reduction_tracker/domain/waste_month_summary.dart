import '../../../core/data/database/app_database.dart';
import 'waste_category.dart';

class WasteMonthSummary {
  const WasteMonthSummary({
    required this.year,
    required this.month,
    required this.totalKgCents,
    required this.categories,
  });

  factory WasteMonthSummary.fromEntries({
    required Iterable<WasteLogEntry> entries,
    required DateTime month,
  }) {
    final categoryTotals = <WasteCategory, double>{};
    var monthTotalKg = 0.0;
    for (final entry in entries) {
      if (entry.wasteDate.year != month.year ||
          entry.wasteDate.month != month.month) {
        continue;
      }
      final category = WasteCategory.fromValue(entry.category);
      categoryTotals.update(
        category,
        (total) => total + entry.amountKg,
        ifAbsent: () => entry.amountKg,
      );
      monthTotalKg += entry.amountKg;
    }

    final totalKgCents = (monthTotalKg * 100).round();
    final categoryCents = {
      for (final entry in categoryTotals.entries)
        entry.key: (entry.value * 100).round(),
    };
    if (categoryCents.isNotEmpty) {
      final adjustmentOrder =
          WasteCategory.values.where(categoryTotals.containsKey).toList()
            ..sort((first, second) {
              final amountOrder = categoryTotals[second]!.compareTo(
                categoryTotals[first]!,
              );
              return amountOrder == 0
                  ? first.index.compareTo(second.index)
                  : amountOrder;
            });
      final roundedCategorySum = categoryCents.values.fold<int>(
        0,
        (total, cents) => total + cents,
      );
      final difference = totalKgCents - roundedCategorySum;
      if (difference > 0) {
        final largestCategory = adjustmentOrder.first;
        categoryCents[largestCategory] =
            categoryCents[largestCategory]! + difference;
      } else if (difference < 0) {
        var centsToRemove = -difference;
        for (final category in adjustmentOrder) {
          final currentCents = categoryCents[category]!;
          final reduction = currentCents < centsToRemove
              ? currentCents
              : centsToRemove;
          categoryCents[category] = currentCents - reduction;
          centsToRemove -= reduction;
          if (centsToRemove == 0) break;
        }
        if (centsToRemove != 0) {
          throw StateError('Waste category totals could not be reconciled.');
        }
      }
    }

    return WasteMonthSummary(
      year: month.year,
      month: month.month,
      totalKgCents: totalKgCents,
      categories: List.unmodifiable([
        for (final category in WasteCategory.values)
          if (categoryCents.containsKey(category))
            WasteCategoryMonthTotal(
              category: category,
              kgCents: categoryCents[category]!,
            ),
      ]),
    );
  }

  final int year;
  final int month;
  final int totalKgCents;
  final List<WasteCategoryMonthTotal> categories;

  double get totalKg => totalKgCents / 100;

  bool get isEmpty => categories.isEmpty;
}

class WasteCategoryMonthTotal {
  const WasteCategoryMonthTotal({
    required this.category,
    required this.kgCents,
  });

  final WasteCategory category;
  final int kgCents;

  double get kg => kgCents / 100;
}
