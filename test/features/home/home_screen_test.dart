import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  testWidgets('renders all required Home modules and About Us for a guest', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    for (final title in _moduleTitles) {
      await tester.scrollUntilVisible(
        find.text(title),
        400,
        scrollable: scrollable,
      );
      expect(
        find.text(title),
        findsOneWidget,
        reason: '$title must be on Home',
      );
    }
    await tester.scrollUntilVisible(
      find.text('About Us'),
      400,
      scrollable: scrollable,
    );
    expect(find.text('About Us'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Register'), findsNothing);

    await tester.tap(find.text('About Us'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Sustainable Living Guide helps'),
      findsOneWidget,
    );
  });

  testWidgets('module entries are accessible buttons that navigate', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();

    final carbonEntry = find.widgetWithText(
      InkWell,
      'Carbon Footprint Tracker',
    );
    expect(carbonEntry, findsOneWidget);
    final semantics = tester.getSemantics(carbonEntry);
    final semanticsData = semantics.getSemanticsData();
    expect(semanticsData.label, 'Carbon Footprint Tracker');
    expect(semanticsData.flagsCollection.isButton, isTrue);
    expect(semanticsData.hasAction(ui.SemanticsAction.tap), isTrue);

    await tester.tap(carbonEntry);
    await tester.pumpAndSettle();

    expect(find.text('Carbon Footprint Tracker'), findsOneWidget);
    expect(
      find.text('No activities logged for this period yet.'),
      findsOneWidget,
    );
  });

  testWidgets('Home remains readable at Very Large text', (tester) async {
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    });

    await tester.pumpWidget(_TestApp(router: router, textScale: 2));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    for (final title in _moduleTitles) {
      await tester.scrollUntilVisible(
        find.text(title),
        300,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expectNoTextOverlapOrClipping(tester, title);
      expect(
        tester.takeException(),
        isNull,
        reason: '$title must not overflow',
      );
    }

    await tester.scrollUntilVisible(
      find.text('About Us'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('About Us'), findsOneWidget);
    expectNoTextOverlapOrClipping(tester, 'About Us');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gallery and Contact Us are available only in secondary nav', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();

    expect(find.text('Image Gallery'), findsNothing);
    expect(find.text('Contact Us'), findsNothing);

    await tester.tap(find.byTooltip('More navigation'));
    await tester.pumpAndSettle();
    expect(find.text('Image Gallery'), findsWidgets);
    expect(find.text('Contact Us'), findsOneWidget);

    await tester.tap(find.text('Image Gallery'));
    await tester.pumpAndSettle();
    expect(find.text('No gallery images are available yet.'), findsOneWidget);
  });
}

const _moduleTitles = [
  'Carbon Footprint Tracker',
  'Eco-Friendly Product Suggestions',
  'Sustainable Living Challenges',
  'Green Certifications & Labels Guide',
  'Waste Reduction Tracker',
  'Sustainable Recipes & Meal Planning',
  'Energy Conservation Tips',
  'Eco-Travel Suggestions',
  'Community Journal',
  'Sustainability Progress Dashboard',
  'Educational Content',
];

class _TestApp extends StatelessWidget {
  const _TestApp({required this.router, this.textScale = 1});

  final RouterConfig<Object> router;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
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
      ),
    );
  }
}
