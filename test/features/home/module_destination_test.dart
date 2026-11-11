import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/home/domain/module_destination.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import 'text_layout_expectations.dart';

void main() {
  testWidgets('all module destinations remain readable at Very Large text', (
    tester,
  ) async {
    for (final destination in ModuleDestination.modules) {
      final router = createAppRouter(initialLocation: destination.path);
      await tester.pumpWidget(_TestApp(router: router, textScale: 2));
      await tester.pumpAndSettle();

      expect(
        find.text('Foundation destination'),
        findsOneWidget,
        reason: '${destination.path} must show its destination title',
      );
      expect(
        find.text('Detailed features will be available in a future update.'),
        findsOneWidget,
        reason: '${destination.path} must show its existing details',
      );
      expectNoTextOverlapOrClipping(tester, destination.path);
      expect(
        tester.takeException(),
        isNull,
        reason: '${destination.path} must not overflow at Very Large text',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    }
  });

  test('registers exactly the required 11 primary module destinations', () {
    expect(
      ModuleDestination.modules.map((destination) => destination.id).toSet(),
      {
        'carbonFootprintTracker',
        'ecoFriendlyProductSuggestions',
        'sustainableLivingChallenges',
        'certificationsGuide',
        'wasteReductionTracker',
        'recipesMealPlanning',
        'energyConservationTips',
        'ecoTravelSuggestions',
        'communityJournal',
        'progressDashboard',
        'educationalContent',
      },
    );
    expect(ModuleDestination.modules, hasLength(11));
    expect(
      ModuleDestination.modules.every(
        (destination) =>
            destination.navigationGroup == NavigationGroup.homePrimary,
      ),
      isTrue,
    );
    expect(
      ModuleDestination.modules.every(
        (destination) =>
            destination.availability == DestinationAvailability.foundationStub,
      ),
      isTrue,
    );
  });

  test('keeps About Us reachable from Home outside the module inventory', () {
    expect(ModuleDestination.aboutUsPath, '/about');
    expect(ModuleDestination.aboutUsTitleKey, 'aboutUs');
  });

  test('provides stable routes and localization keys for every module', () {
    final paths = ModuleDestination.modules
        .map((destination) => destination.path)
        .toSet();
    final titleKeys = ModuleDestination.modules
        .map((destination) => destination.titleKey)
        .toSet();

    expect(paths, hasLength(11));
    expect(titleKeys, hasLength(11));
    expect(paths, isNot(contains('/gallery')));
    expect(paths, isNot(contains('/contact')));
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.router, required this.textScale});

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
