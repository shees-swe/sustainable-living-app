import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profiles onboarding and Home navigation transitions', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutes.onboarding);
    addTearDown(router.dispose);
    final frameTimings = <ui.FrameTiming>[];
    void collectFrameTimings(List<ui.FrameTiming> timings) {
      frameTimings.addAll(timings);
    }

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
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
    expect(find.text('Skip and continue as guest'), findsOneWidget);

    binding.addTimingsCallback(collectFrameTimings);
    await tester.tap(find.text('Skip and continue as guest'));
    await _pumpTransitionFrames(tester);
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
    expect(find.text('Explore sustainable living'), findsOneWidget);

    await tester.tap(find.text('Carbon Footprint Tracker'));
    await _pumpTransitionFrames(tester);
    binding.removeTimingsCallback(collectFrameTimings);

    expect(find.text('Carbon Footprint Tracker'), findsWidgets);
    expect(frameTimings, isNotEmpty);

    final frameCosts =
        frameTimings.map((timing) => timing.totalSpan.inMicroseconds).toList()
          ..sort();
    final p95 = frameCosts[(frameCosts.length * 0.95).ceil() - 1];
    // ignore: avoid_print
    print(
      'FOUNDATION_MOTION frames=${frameCosts.length} '
      'p95FrameSpanUs=$p95 frameBudgetUs=16667',
    );
    expect(
      p95,
      lessThanOrEqualTo(16667),
      reason: 'Release-mode standard navigation must meet 60 fps.',
    );
  });
}

Future<void> _pumpTransitionFrames(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 500)),
  );
  await tester.pump();
}
