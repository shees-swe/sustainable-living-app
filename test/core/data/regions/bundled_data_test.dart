import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/regions/foundation_references.dart';
import 'package:sustainable_living_app/core/data/regions/region_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled regional packs resolve canonical factors and citations',
    () async {
      final repository = await RegionRepository.loadBundled();
      final pakistan = repository.requireRegion('PK');

      expect(repository.regionIds, ['PK']);
      expect(pakistan.region.currencyCode, 'PKR');
      expect(pakistan.emissionFactors, hasLength(1));
      expect(pakistan.emissionFactors.single.value, 0.347);
      expect(pakistan.emissionFactors.single.sourceYear, 2025);
      expect(pakistan.emissionFactors.single.validFrom, '2025-01-01');
      expect(pakistan.transportModes, isEmpty);
      expect(pakistan.recipes, isEmpty);
    },
  );

  test(
    'bundled references preserve the specified values and provenance',
    () async {
      final references = await FoundationReferences.loadBundled();

      expect(references.globalAverage.value, 4.7);
      expect(references.globalAverage.unit, 't CO2/person');
      expect(references.globalAverage.period, '2024');
      expect(
        references.sources[references.globalAverage.sourceId]!.publicationYear,
        2025,
      );
      expect(references.temperatureBudget.reference.value, 2.5);
      expect(references.temperatureBudget.reference.unit, 't CO2e/person/year');
      expect(references.temperatureBudget.targetYear, 2030);
      expect(
        references
            .sources[references.temperatureBudget.reference.sourceId]!
            .publicationYear,
        2021,
      );
    },
  );
}
