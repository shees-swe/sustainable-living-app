import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/account/data/account_repository.dart';
import 'package:sustainable_living_app/features/account/data/password_hasher.dart';
import 'package:sustainable_living_app/features/account/presentation/account_screen.dart';
import 'package:sustainable_living_app/features/home/presentation/home_screen.dart';
import 'package:sustainable_living_app/features/onboarding/data/estimate_demo_fixtures.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_calculator.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_estimate.dart';
import 'package:sustainable_living_app/features/onboarding/domain/reference_comparison.dart';
import 'package:sustainable_living_app/features/onboarding/domain/reference_value.dart';
import 'package:sustainable_living_app/features/onboarding/presentation/comparison_rings.dart';
import 'package:sustainable_living_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:sustainable_living_app/features/settings/data/user_data_deleter.dart';
import 'package:sustainable_living_app/features/settings/data/user_data_exporter.dart';
import 'package:sustainable_living_app/features/settings/presentation/settings_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('Home controls meet accessibility guidelines at 200% text', (
    tester,
  ) async {
    await tester.pumpWidget(_TestApp(textScale: 2, child: const HomeScreen()));
    await _expectAccessibilityGuidelines(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'onboarding controls meet accessibility guidelines at 200% text',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(textScale: 2, child: const OnboardingScreen()),
      );
      await tester.tap(find.byType(RadioListTile<String>).first);
      await tester.pump();

      await _expectAccessibilityGuidelines(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('account controls meet accessibility guidelines', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: AccountScreen(
          repository: AccountRepository(
            database: database,
            passwordHasher: const PasswordHasher(),
          ),
        ),
      ),
    );

    await _expectAccessibilityGuidelines(tester);
  });

  testWidgets('Settings controls meet accessibility guidelines', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: SettingsScreen(
          exporter: UserDataExporter(database: database),
          deleter: UserDataDeleter(
            database: database,
            closeDatabase: () async {},
            deleteDatabaseFiles: () async {},
            onGuestReset: () async {},
          ),
          onGuestReturn: () async {},
        ),
      ),
    );

    await _expectAccessibilityGuidelines(tester);
  });

  testWidgets('Home keyboard focus follows visual reading order', (
    tester,
  ) async {
    await tester.pumpWidget(_TestApp(child: const HomeScreen()));

    final firstFocus = Focus.of(
      tester.element(find.text('Carbon Footprint Tracker')),
    );
    final secondFocus = Focus.of(
      tester.element(find.text('Eco-Friendly Product Suggestions')),
    );

    firstFocus.requestFocus();
    await tester.pump();
    expect(firstFocus.hasFocus, isTrue);

    expect(firstFocus.nextFocus(), isTrue);
    await tester.pump();
    expect(secondFocus.hasFocus, isTrue);
  });

  testWidgets('comparison ring retains a complete semantic description', (
    tester,
  ) async {
    final region = foundationEstimateDemoRegions.single;
    final estimate = FootprintCalculator().calculate(
      answers: const FootprintAnswers(
        questionnaireVersion: '1',
        periodYear: 2026,
        activities: [
          ActivityInput(activityId: 'electricity', amount: 100, unit: 'kWh'),
        ],
      ),
      factors: [region.factors.first],
    ) as CompleteEstimate;
    final comparison = const ReferenceComparisonService().compare(
      estimate: EstimateComparisonBasis(
        value: 25,
        unit: 'kg CO2e/year',
        period: '2026',
        accountingBoundary: 'annual consumption footprint per person',
      ),
      reference: region.references.first,
      sources: {region.source.sourceId: region.source},
    );

    await tester.pumpWidget(
      _TestApp(
        child: ComparisonRing(
          label: 'Regional average',
          estimate: estimate,
          comparison: comparison,
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(
        RegExp('Regional average\\. 25\\.00 kg CO2e/year; reference'),
      ),
      findsOneWidget,
    );
  });
}

Future<void> _expectAccessibilityGuidelines(WidgetTester tester) async {
  final semantics = tester.ensureSemantics();
  try {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  } finally {
    semantics.dispose();
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScale = 1});

  final Widget child;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: child,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
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
