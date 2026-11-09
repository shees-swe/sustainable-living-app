import 'package:intl/intl.dart';

import 'region_repository.dart';

class RegionCatalog {
  const RegionCatalog({required this.regions});

  factory RegionCatalog.fromRepository(
    RegionRepository repository, {
    bool includeDemoRegion = true,
  }) {
    return RegionCatalog(
      regions: [
        for (final pack in repository.packs)
          RegionCatalogEntry(
            regionId: pack.region.regionId,
            nameKey: pack.region.nameKey,
            currencyCode: pack.region.currencyCode,
          ),
        if (includeDemoRegion)
          const RegionCatalogEntry(
            regionId: 'demo-region',
            nameKey: 'regionDemoOnly',
            currencyCode: 'USD',
            demoOnly: true,
          ),
      ],
    );
  }

  final List<RegionCatalogEntry> regions;

  RegionCatalogEntry? regionById(String regionId) {
    for (final region in regions) {
      if (region.regionId == regionId) return region;
    }
    return null;
  }

  static String formatCurrency(
    num amount, {
    required String currencyCode,
    required String locale,
  }) {
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'Must be an ISO 4217 code.',
      );
    }
    if (!amount.isFinite) {
      throw ArgumentError.value(amount, 'amount', 'Must be finite.');
    }
    return NumberFormat.currency(
      locale: locale,
      name: currencyCode,
    ).format(amount);
  }
}

class RegionCatalogEntry {
  const RegionCatalogEntry({
    required this.regionId,
    required this.nameKey,
    required this.currencyCode,
    this.demoOnly = false,
  });

  final String regionId;
  final String nameKey;
  final String currencyCode;
  final bool demoOnly;
}
