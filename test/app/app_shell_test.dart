import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/app_shell.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/theme/living_theme.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

/// A realistic 400x800 dp phone. The default test surface is only about
/// 266x200 dp, which is too small to reach content below the first fold.
void _phoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  group('AppTab.fromLocation', () {
    test('maps every route family to its tab', () {
      expect(AppTab.fromLocation('/home'), AppTab.home);
      expect(AppTab.fromLocation('/carbon-footprint'), AppTab.track);
      expect(AppTab.fromLocation('/waste-tracker'), AppTab.track);
      expect(AppTab.fromLocation('/challenges'), AppTab.goals);
      expect(AppTab.fromLocation('/progress'), AppTab.goals);
      expect(AppTab.fromLocation('/explore'), AppTab.explore);
      expect(AppTab.fromLocation('/product-suggestions'), AppTab.explore);
      expect(AppTab.fromLocation('/recipes'), AppTab.explore);
      expect(AppTab.fromLocation('/you'), AppTab.you);
      expect(AppTab.fromLocation('/settings'), AppTab.you);
      expect(AppTab.fromLocation('/community-journal'), AppTab.you);
      expect(AppTab.fromLocation('/about'), AppTab.you);
    });

    test('falls back to Home and matches whole path segments only', () {
      expect(AppTab.fromLocation('/unknown'), AppTab.home);
      expect(AppTab.fromLocation('/exploring'), AppTab.home);
      expect(AppTab.fromLocation('/recipes/42'), AppTab.explore);
    });
  });

  testWidgets('tab bar switches between Home and Explore', (tester) async {
    _phoneSurface(tester);
    final router = createAppRouter(
      initialLocation: AppRoutes.home,
      useTabShell: true,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();

    expect(find.text('Your week'), findsOneWidget);
    for (final tab in ['Track', 'Goals', 'Explore', 'You']) {
      expect(find.byTooltip(tab), findsOneWidget, reason: '$tab tab');
    }

    await tester.tap(find.byTooltip('Explore'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, AppRoutes.explore);
    expect(find.text('Explore sustainable living'), findsOneWidget);
    expect(find.text('Eco-Friendly Product Suggestions'), findsOneWidget);
    expect(find.text('Educational Content'), findsOneWidget);
  });

  testWidgets('quick action opens a module under the shell and Back returns', (
    tester,
  ) async {
    _phoneSurface(tester);
    final router = createAppRouter(
      initialLocation: AppRoutes.home,
      useTabShell: true,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add activity').first);
    await tester.pumpAndSettle();

    expect(
      find.text('No activities logged for this period yet.'),
      findsOneWidget,
    );
    // The Track tab is now the selected one, so its label is visible.
    expect(find.text('Track'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Your week'), findsOneWidget);
  });

  testWidgets('tab bar stays compact and never overflows, even on the tiny '
      'default test surface', (tester) async {
    final router = createAppRouter(
      initialLocation: AppRoutes.home,
      useTabShell: true,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();

    final bar = tester.getSize(find.byType(LivingNavBar));
    expect(bar.height, lessThan(100), reason: 'bar must not fill the screen');
    expect(find.text('Your week'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legacy router without the shell is unchanged', (tester) async {
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(_TestApp(router: router));
    await tester.pumpAndSettle();

    expect(find.byTooltip('More navigation'), findsOneWidget);
    expect(find.byTooltip('Explore'), findsNothing);
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
