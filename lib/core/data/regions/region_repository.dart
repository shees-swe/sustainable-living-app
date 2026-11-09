import 'dart:convert';

import 'package:flutter/services.dart';

import 'emission_factor.dart';
import 'region_pack_parser.dart';

class RegionRepository {
  RegionRepository({
    required Iterable<RegionDataPack> packs,
    CanonicalEmissionFactorCatalog catalog =
        const CanonicalEmissionFactorCatalog(),
  }) : _catalog = catalog,
       _packs = _validatePacks(packs, catalog);

  final CanonicalEmissionFactorCatalog _catalog;
  final Map<String, RegionDataPack> _packs;

  List<RegionDataPack> get packs => List.unmodifiable(_packs.values);
  List<String> get regionIds => List.unmodifiable(_packs.keys);
  String get factorCatalogVersion => _catalog.version;

  RegionDataPack? regionById(String regionId) => _packs[regionId];

  RegionDataPack requireRegion(String regionId) {
    final region = regionById(regionId);
    if (region == null) {
      throw UnknownRegion(regionId);
    }
    return region;
  }

  static Future<RegionRepository> loadBundled({
    AssetBundle? bundle,
    RegionPackParser parser = const RegionPackParser(),
    CanonicalEmissionFactorCatalog catalog =
        const CanonicalEmissionFactorCatalog(),
  }) async {
    final assetBundle = bundle ?? rootBundle;
    final indexSource = await assetBundle.loadString(
      'assets/data/regions/index.json',
    );
    final decodedIndex = jsonDecode(indexSource);
    if (decodedIndex is! Map<String, dynamic> ||
        decodedIndex['packFiles'] is! List) {
      throw const FormatException('Regional data pack index is invalid.');
    }
    final packFiles = (decodedIndex['packFiles'] as List)
        .map((path) {
          if (path is! String || !path.startsWith('assets/data/regions/')) {
            throw const FormatException('Regional pack path is invalid.');
          }
          return path;
        })
        .toList(growable: false);
    if (packFiles.isEmpty) {
      throw const FormatException('No regional data packs are bundled.');
    }
    final packs = <RegionDataPack>[];
    for (final path in packFiles) {
      packs.add(parser.parseJson(await assetBundle.loadString(path)));
    }
    return RegionRepository(packs: packs, catalog: catalog);
  }

  static Map<String, RegionDataPack> _validatePacks(
    Iterable<RegionDataPack> packs,
    CanonicalEmissionFactorCatalog catalog,
  ) {
    if (catalog.version != CanonicalEmissionFactorCatalog.currentVersion) {
      throw UnsupportedError(
        'Unsupported factor catalog version "${catalog.version}".',
      );
    }
    final regions = <String, RegionDataPack>{};
    for (final pack in packs) {
      if (pack.factorCatalogVersion != catalog.version) {
        throw FormatException(
          'Pack "${pack.packId}" uses factor catalog '
          '"${pack.factorCatalogVersion}", expected "${catalog.version}".',
        );
      }
      if (regions.containsKey(pack.region.regionId)) {
        throw FormatException(
          'Duplicate regional pack for "${pack.region.regionId}".',
        );
      }
      for (final factor in pack.emissionFactors) {
        final definition = catalog.definitionFor(factor.factorId);
        if (definition == null) {
          throw FormatException(
            'Factor "${factor.factorId}" is not in the canonical catalog.',
          );
        }
        if (factor.category != definition.category ||
            factor.activityId != definition.activityId ||
            factor.numeratorUnit != definition.numeratorUnit ||
            factor.denominatorUnit != definition.denominatorUnit ||
            factor.sourceYear != factor.source.publicationYear ||
            factor.sourceId != factor.source.sourceId) {
          throw FormatException(
            'Factor "${factor.factorId}" redefines canonical metadata or '
            'does not carry its own matching source and publication year.',
          );
        }
      }
      regions[pack.region.regionId] = pack;
    }
    if (regions.isEmpty) {
      throw const FormatException(
        'At least one regional data pack is required.',
      );
    }
    return Map.unmodifiable(regions);
  }
}

class UnknownRegion implements Exception {
  const UnknownRegion(this.regionId);

  final String regionId;

  @override
  String toString() => 'UnknownRegion: $regionId';
}
