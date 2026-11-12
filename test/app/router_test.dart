import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/home/domain/module_destination.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../support/text_layout_expectations.dart';

void main() {
  testWidgets('guest can open Home without an account redirect', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
    expect(find.text('Sustainable Living Guide'), findsOneWidget);
  });

  testWidgets('route changes use the shared 120 ms fade', (tester) async {
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Carbon Footprint Tracker'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    var transition = tester.widget<FadeTransition>(
      find.byType(FadeTransition).last,
    );
    expect(transition.opacity.value, greaterThan(0));
    expect(transition.opacity.value, lessThan(1));

    await tester.pump(const Duration(milliseconds: 60));
    transition = tester.widget<FadeTransition>(
      find.byType(FadeTransition).last,
    );
    expect(transition.opacity.value, 1);
  });

  testWidgets('system Back from a module destination returns to Home', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Carbon Footprint Tracker'));
    await tester.pumpAndSettle();

    expect(find.text('Carbon Footprint Tracker'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
    expect(find.text('Sustainable Living Guide'), findsOneWidget);
  });

  testWidgets('system Back from Settings returns to Home', (tester) async {
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsNWidgets(2));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
    expect(find.text('Sustainable Living Guide'), findsOneWidget);
  });

  testWidgets('all 11 module routes are registered for guest navigation', (
    tester,
  ) async {
    for (final destination in ModuleDestination.modules) {
      final router = createAppRouter(initialLocation: destination.path);
      addTearDown(router.dispose);

      await tester.pumpWidget(_TestApp(router: router));
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.path,
        destination.path,
        reason: '${destination.path} should be available without login',
      );
      if (destination.id == 'carbonFootprintTracker') {
        expect(
          find.text('No activities logged for this period yet.'),
          findsOneWidget,
        );
      } else {
        expect(find.text('Foundation destination'), findsOneWidget);
        expect(
          find.text('Detailed features will be available in a future update.'),
          findsOneWidget,
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('About Us and secondary destinations have stable routes', (
    tester,
  ) async {
    for (final path in [
      AppRoutes.about,
      AppRoutes.gallery,
      AppRoutes.contact,
      AppRoutes.account,
      AppRoutes.settings,
      AppRoutes.onboarding,
    ]) {
      final router = createAppRouter(initialLocation: path);
      addTearDown(router.dispose);

      await tester.pumpWidget(_TestApp(router: router));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, path);
      if (path == AppRoutes.about) {
        expect(
          find.textContaining('Sustainable Living Guide helps'),
          findsOneWidget,
        );
      } else if (path == AppRoutes.gallery) {
        expect(
          find.text('No gallery images are available yet.'),
          findsOneWidget,
        );
      } else if (path == AppRoutes.contact) {
        expect(
          find.text(
            'Contact information is not available in this foundation version.',
          ),
          findsOneWidget,
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('About, Gallery, and Contact remain readable at Very Large text', (
    tester,
  ) async {
    for (final route in [
      AppRoutes.about,
      AppRoutes.gallery,
      AppRoutes.contact,
    ]) {
      final router = createAppRouter(initialLocation: route);
      await tester.pumpWidget(_TestApp(router: router, textScale: 2));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, route);
      expectNoTextOverlapOrClipping(tester, route);
      expect(tester.takeException(), isNull);
      if (route == AppRoutes.about) {
        expect(
          find.textContaining('Sustainable Living Guide helps'),
          findsOneWidget,
        );
      } else if (route == AppRoutes.gallery) {
        expect(
          find.text('No gallery images are available yet.'),
          findsOneWidget,
        );
      } else {
        expect(
          find.text(
            'Contact information is not available in this foundation version.',
          ),
          findsOneWidget,
        );
      }

      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    }
  });
}

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
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    );
  }
}
