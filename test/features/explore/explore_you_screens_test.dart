import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/theme/living_theme.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

void main() {
  void tallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('Explore hub lists the six Explore modules', (tester) async {
    tallSurface(tester);
    final router = createAppRouter(initialLocation: AppRoutes.explore);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();

    for (final title in const [
      'Eco-Friendly Product Suggestions',
      'Eco-Travel Suggestions',
      'Sustainable Recipes & Meal Planning',
      'Green Certifications & Labels Guide',
      'Energy Conservation Tips',
      'Educational Content',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    // Modules that live on other tabs are not duplicated here.
    expect(find.text('Waste Reduction Tracker'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Explore tile opens its module route', (tester) async {
    tallSurface(tester);
    final router = createAppRouter(initialLocation: AppRoutes.explore);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Energy Conservation Tips'));
    await tester.pumpAndSettle();

    // go_router does not update routeInformationProvider on push(), so assert
    // on the destination screen's own AppBar instead of the route path.
    expect(
      find.widgetWithText(AppBar, 'Energy Conservation Tips'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('You tab shows the guest account note and app links', (
    tester,
  ) async {
    tallSurface(tester);
    final router = createAppRouter(initialLocation: AppRoutes.you);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();

    expect(
      find.text('Account is optional. You can browse as a guest.'),
      findsOneWidget,
    );
    for (final title in const [
      'Community Journal',
      'Settings',
      'Privacy policy',
      'About Us',
      'Image Gallery',
      'Contact Us',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
    }

    await tester.tap(find.text('Image Gallery'));
    await tester.pumpAndSettle();
    expect(find.text('No gallery images are available yet.'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.router});

  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context) => ProviderScope(
    child: MaterialApp.router(
      theme: LivingTheme.light,
      routerConfig: router,
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
