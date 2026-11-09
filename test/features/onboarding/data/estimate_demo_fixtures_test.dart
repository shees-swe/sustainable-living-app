import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/features/onboarding/data/estimate_demo_fixtures.dart';

void main() {
  test('contains only explicitly demo-labeled estimate fixtures', () {
    expect(foundationEstimateDemoRegions, hasLength(1));
    expect(foundationEstimateDemoRegions.single.demoOnly, isTrue);
    expect(foundationEstimateDemoRegions.single.factors, hasLength(2));
    expect(foundationEstimateDemoRegions.single.references, hasLength(3));
    expect(
      foundationEstimateDemoRegions.single.labelKey,
      'regionDemoOnly',
    );
  });
}
