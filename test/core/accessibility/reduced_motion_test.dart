import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/accessibility/motion_aware_progress_indicator.dart';
import 'package:sustainable_living_app/core/accessibility/reduced_motion.dart';
import 'package:sustainable_living_app/core/motion/motion_spec.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/core/widgets/app_skeleton.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('respects the $platform reduced-motion signal', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        bool? reducedMotion;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                reducedMotion = ReducedMotion.isEnabled(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(reducedMotion, isTrue);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('a user override cannot disable platform reduced motion', (
    tester,
  ) async {
    bool? reducedMotion;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            reducedMotion = ReducedMotion.isEnabled(
              context,
              userOverride: false,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(reducedMotion, isTrue);
  });

  testWidgets('reduced motion makes the shared fade duration instant', (
    tester,
  ) async {
    Duration? duration;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            duration = ReducedMotion.duration(context, MotionSpec.optionalFade);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(duration, Duration.zero);
  });

  testWidgets('skeleton loading keeps an accessible label without animation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(body: AppSkeleton(semanticsLabel: 'Loading estimate')),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate((widget) => widget is Skeletonizer),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Loading estimate'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('reduced motion replaces the animated progress indicator', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const MaterialApp(
          home: MotionAwareProgressIndicator(semanticsLabel: 'Loading'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('reduced motion does not prevent onboarding completion', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final router = createAppRouter(initialLocation: AppRoutes.onboarding);
    try {
      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
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
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip and continue as guest'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
      expect(find.text('Explore sustainable living'), findsOneWidget);
    } finally {
      router.dispose();
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('reduced motion skips route fades', (tester) async {
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
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
    await tester.pumpAndSettle();
    router.go(AppRoutes.about);
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, AppRoutes.about);
    expect(
      find.byKey(const ValueKey('appRouteFade-${AppRoutes.about}')),
      findsNothing,
    );
  });
}
