import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/energy_conservation_tips/data/energy_tip_catalog.dart';
import 'package:sustainable_living_app/features/energy_conservation_tips/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EnergyTipCatalog catalog;

  setUpAll(() async {
    catalog = await EnergyTipCatalog.loadBundled();
  });

  testWidgets('search narrows rows by title and text', (tester) async {
    await _openTips(tester, catalog);
    final search = find.byKey(const ValueKey('energyTipSearchField'));

    await tester.enterText(search, 'Switch to LED bulbs');
    await tester.pump();
    expect(
      find.byKey(const ValueKey('energyTip-Switch to LED bulbs')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('energyTip-Use daylight first')),
      findsNothing,
    );

    await tester.enterText(search, 'door sweeps keep the air');
    await tester.pump();
    expect(
      find.byKey(
        const ValueKey('energyTip-Seal gaps around doors and windows'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('energyTip-Switch to LED bulbs')),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('category filter shows only the selected category', (
    tester,
  ) async {
    await _openTips(tester, catalog);
    await tester.tap(find.byKey(const ValueKey('energyTipCategoryFilter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lighting').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('energyTip-Switch to LED bulbs')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('energyTip-Use daylight first')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('energyTip-Use fans before air conditioning')),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('search and category filters combine', (tester) async {
    await _openTips(tester, catalog);
    await tester.tap(find.byKey(const ValueKey('energyTipCategoryFilter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Appliances').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('energyTipSearchField')),
      'power strip',
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('energyTip-Kill standby power')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('energyTip-Run full loads')),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('no-match state offers to clear search and category', (
    tester,
  ) async {
    await _openTips(tester, catalog);
    await tester.enterText(
      find.byKey(const ValueKey('energyTipSearchField')),
      'not an energy tip',
    );
    await tester.pump();

    expect(
      find.text('No energy tips match your current search and category.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Clear search and category'));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('energyTip-Use fans before air conditioning')),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tips remain readable at 200% text', (tester) async {
    await _openTips(tester, catalog, textScale: 2);
    expectNoTextOverlapOrClipping(tester, 'energy tips at 200% text');

    final lastTip = find.byKey(
      const ValueKey('energyTip-Take one small solar step'),
    );
    await tester.scrollUntilVisible(
      lastTip,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.textContaining(
        'solar garden lights, a solar power bank, or a solar water heater each cut one slice of grid use.',
      ),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(lastTip, findsOneWidget);
    expectNoTextOverlapOrClipping(
      tester,
      'last energy tip at 200% text',
      within: find.byKey(const ValueKey('energyTipsList')),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _openTips(
  WidgetTester tester,
  EnergyTipCatalog catalog, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _TestApp(
      textScale: textScale,
      child: EnergyConservationTipsScreen(catalog: catalog),
    ),
  );
  await tester.pumpAndSettle();
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, required this.textScale});

  final Widget child;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: child,
    ),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}
