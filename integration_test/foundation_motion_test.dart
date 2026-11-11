import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sustainable_living_app/app/app.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/home/domain/module_destination.dart';

const _repeatCount = 3;
const _steadyStateFrameCount = 600;
const _warmupFrameCount = 30;
const _framePeriod = Duration(milliseconds: 16);
const _frameTimingFlushDelay = Duration(seconds: 2);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('T061 profiles onboarding through estimate result', (
    tester,
  ) async {
    tester.testTextInput.register();
    try {
      await _runRepeatedScenario(
        binding: binding,
        tester: tester,
        scenario: 'onboarding_to_estimate',
        action: () async {
          const scenario = 'onboarding_to_estimate';
          await _runScenarioStep(
            scenario,
            'select demo region',
            () => tester.tap(find.text('Demo region (demo only)')),
          );
          await _runScenarioStep(
            scenario,
            'wait for estimate inputs',
            () => _pumpAndSettleBounded(
              tester,
              scenario: scenario,
              step: 'wait for estimate inputs',
            ),
          );
          final electricityInput = find.byKey(
            const ValueKey('electricityInput'),
          );
          await _runScenarioStep(
            scenario,
            'make electricity input visible',
            () => tester.ensureVisible(electricityInput),
          );
          await _runScenarioStep(
            scenario,
            'enter annual electricity',
            () async {
              await tester.enterText(electricityInput, '100');
              await tester.pump(const Duration(milliseconds: 100));
              expect(
                tester.widget<TextField>(electricityInput).controller?.text,
                '100',
              );
            },
          );
          final travelInput = find.byKey(const ValueKey('travelInput'));
          await _runScenarioStep(
            scenario,
            'make travel input visible',
            () => tester.ensureVisible(travelInput),
          );
          await _runScenarioStep(scenario, 'enter annual travel', () async {
            await tester.enterText(travelInput, '200');
            await tester.pump(const Duration(milliseconds: 100));
            expect(
              tester.widget<TextField>(travelInput).controller?.text,
              '200',
            );
          });
          await _runScenarioStep(scenario, 'dismiss keyboard', () async {
            FocusManager.instance.primaryFocus?.unfocus();
            tester.testTextInput.hide();
            await tester.pump(const Duration(milliseconds: 100));
          });
          final calculateButton = find.text('Calculate demo estimate');
          await _runScenarioStep(
            scenario,
            'make calculate button visible',
            () => tester.ensureVisible(calculateButton),
          );
          expect(calculateButton, findsOneWidget);
          await _runScenarioStep(
            scenario,
            'calculate estimate',
            () => tester.tap(calculateButton),
          );
          await _runScenarioStep(
            scenario,
            'wait for estimate result',
            () => _pumpUntilVisible(
              tester,
              find.text('Your estimated footprint'),
            ),
          );
        },
      );
    } finally {
      tester.testTextInput.hide();
      tester.testTextInput.unregister();
    }
  });

  testWidgets('T061 profiles Home and all module destinations', (tester) async {
    await _runRepeatedScenario(
      binding: binding,
      tester: tester,
      scenario: 'home_and_all_modules',
      action: () async {
        await tester.tap(find.text('Skip and continue as guest'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'home_and_all_modules',
          step: 'open Home',
        );

        for (final destination in ModuleDestination.modules) {
          final title = _moduleTitle(destination.titleKey);
          await tester.scrollUntilVisible(
            find.text(title),
            400,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(find.text(title));
          await _pumpAndSettleBounded(
            tester,
            scenario: 'home_and_all_modules',
            step: 'open $title',
          );
          expect(find.text('Foundation destination'), findsOneWidget);
          await tester.binding.handlePopRoute();
          await _pumpAndSettleBounded(
            tester,
            scenario: 'home_and_all_modules',
            step: 'return from $title',
          );
        }
        expect(find.text('Sustainable Living Guide'), findsOneWidget);
      },
    );
  });

  testWidgets('T061 profiles account registration and sign-in surfaces', (
    tester,
  ) async {
    await _runRepeatedScenario(
      binding: binding,
      tester: tester,
      scenario: 'account',
      action: () async {
        await tester.tap(find.text('Skip and continue as guest'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'account',
          step: 'open Home',
        );
        await tester.tap(find.byTooltip('More navigation'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'account',
          step: 'open navigation menu',
        );
        await tester.tap(find.text('Account'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'account',
          step: 'open Account',
        );
        expect(
          find.text('Account is optional. You can browse as a guest.'),
          findsOneWidget,
        );
        expect(find.text('Register'), findsWidgets);
        await tester.tap(find.text('Log in').last);
        await _pumpAndSettleBounded(
          tester,
          scenario: 'account',
          step: 'open sign-in mode',
        );
        expect(find.text('Log in'), findsWidgets);
        await tester.tap(find.text('Register').last);
        await _pumpAndSettleBounded(
          tester,
          scenario: 'account',
          step: 'open registration mode',
        );
        expect(find.text('Create local account'), findsOneWidget);
        await tester.tap(find.text('Log in').last);
        await _pumpAndSettleBounded(
          tester,
          scenario: 'account',
          step: 'return to sign-in mode',
        );
        expect(find.byKey(const ValueKey('accountIdentifier')), findsOneWidget);
        expect(find.byKey(const ValueKey('accountPassword')), findsOneWidget);
      },
    );
  });

  testWidgets('T061 profiles regional Settings and privacy policy', (
    tester,
  ) async {
    await _runRepeatedScenario(
      binding: binding,
      tester: tester,
      scenario: 'settings_and_privacy',
      action: () async {
        await tester.tap(find.text('Skip and continue as guest'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'settings_and_privacy',
          step: 'open Home',
        );
        await tester.tap(find.byTooltip('More navigation'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'settings_and_privacy',
          step: 'open navigation menu',
        );
        await tester.tap(find.text('Settings'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'settings_and_privacy',
          step: 'open Settings',
        );
        await tester.scrollUntilVisible(
          find.text('Pakistan'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Pakistan'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'settings_and_privacy',
          step: 'select Pakistan region',
        );
        await tester.scrollUntilVisible(
          find.text('Privacy policy'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Privacy policy'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'settings_and_privacy',
          step: 'open Privacy policy',
        );
        expect(find.text('Privacy policy'), findsWidgets);
      },
    );
  });

  testWidgets('T061 profiles About Us, Gallery, and Contact destinations', (
    tester,
  ) async {
    await _runRepeatedScenario(
      binding: binding,
      tester: tester,
      scenario: 'secondary_destinations',
      action: () async {
        await tester.tap(find.text('Skip and continue as guest'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'secondary_destinations',
          step: 'open Home',
        );
        await tester.scrollUntilVisible(
          find.text('About Us'),
          400,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('About Us'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'secondary_destinations',
          step: 'open About Us',
        );
        expect(
          find.textContaining('Sustainable Living Guide helps'),
          findsOneWidget,
        );
        await tester.binding.handlePopRoute();
        await _pumpAndSettleBounded(
          tester,
          scenario: 'secondary_destinations',
          step: 'return from About Us',
        );
        await tester.tap(find.byTooltip('More navigation'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'secondary_destinations',
          step: 'open navigation menu for Gallery',
        );
        await tester.tap(find.text('Image Gallery'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'secondary_destinations',
          step: 'open Gallery',
        );
        expect(
          find.text('No gallery images are available yet.'),
          findsOneWidget,
        );
        await tester.binding.handlePopRoute();
        await _pumpAndSettleBounded(
          tester,
          scenario: 'secondary_destinations',
          step: 'return from Gallery',
        );
        await tester.tap(find.byTooltip('More navigation'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'secondary_destinations',
          step: 'open navigation menu for Contact',
        );
        await tester.tap(find.text('Contact Us'));
        await _pumpAndSettleBounded(
          tester,
          scenario: 'secondary_destinations',
          step: 'open Contact Us',
        );
        expect(
          find.text(
            'Contact information is not available in this foundation version.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}

Future<void> _runRepeatedScenario({
  required IntegrationTestWidgetsFlutterBinding binding,
  required WidgetTester tester,
  required String scenario,
  required Future<void> Function() action,
}) async {
  final scenarioTimings = <ui.FrameTiming>[];

  for (var repeat = 1; repeat <= _repeatCount; repeat++) {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      await tester.pumpWidget(SustainableLivingApp(database: database));
      await _pumpUntilVisible(tester, find.text('Choose a region'));

      final reportKey = 't061_${scenario}_repeat_$repeat';
      await binding.traceAction(action, reportKey: reportKey);
      await _pumpAndSettleBounded(
        tester,
        scenario: scenario,
        step: 'post-interaction settle for repeat $repeat',
      );

      for (var frame = 0; frame < _warmupFrameCount; frame++) {
        await tester.pump(_framePeriod);
      }

      final frameTimings = <ui.FrameTiming>[];
      void collectFrameTimings(List<ui.FrameTiming> timings) {
        frameTimings.addAll(timings);
      }

      binding.addTimingsCallback(collectFrameTimings);
      for (var frame = 0; frame < _steadyStateFrameCount; frame++) {
        await tester.pump(_framePeriod);
      }
      await tester.runAsync(() => Future<void>.delayed(_frameTimingFlushDelay));
      binding.removeTimingsCallback(collectFrameTimings);

      expect(
        frameTimings.length,
        greaterThanOrEqualTo(_steadyStateFrameCount),
        reason:
            '$scenario repeat $repeat must collect at least '
            '$_steadyStateFrameCount steady-state frames.',
      );

      scenarioTimings.addAll(frameTimings);
      final summary = _summarize(frameTimings);
      final reportData = binding.reportData ??= <String, dynamic>{};
      final timingReports = reportData.putIfAbsent(
        't061_frame_timing_reports',
        () {
          return <String, dynamic>{};
        },
      ) as Map<String, dynamic>;
      timingReports[reportKey] = {
        'scenario': scenario,
        'repeat': repeat,
        'frameCount': frameTimings.length,
        ...summary,
      };
      // ignore: avoid_print
      print(
        'T061 scenario=$scenario repeat=$repeat '
        'frames=${frameTimings.length} '
        'build_p95_us=${summary['buildDurationUs']['p95']} '
        'raster_p95_us=${summary['rasterDurationUs']['p95']} '
        'total_span_p95_us=${summary['totalSpanUs']['p95']} '
        'build_gate=${summary['buildP95Pass']} '
        'raster_gate=${summary['rasterP95Pass']}',
      );
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await database.close();
    }
  }

  final combinedSummary = _summarize(scenarioTimings);
  final reportData = binding.reportData ??= <String, dynamic>{};
  final scenarioReports = reportData.putIfAbsent('t061_scenario_summaries', () {
    return <String, dynamic>{};
  }) as Map<String, dynamic>;
  scenarioReports[scenario] = {
    'repeatCount': _repeatCount,
    'frameCount': scenarioTimings.length,
    ...combinedSummary,
  };
  // ignore: avoid_print
  print(
    'T061 scenario=$scenario combined_frames=${scenarioTimings.length} '
    'build_p95_us=${combinedSummary['buildDurationUs']['p95']} '
    'raster_p95_us=${combinedSummary['rasterDurationUs']['p95']} '
    'total_span_p95_us=${combinedSummary['totalSpanUs']['p95']} '
    'build_gate=${combinedSummary['buildP95Pass']} '
    'raster_gate=${combinedSummary['rasterP95Pass']}',
  );
}

Map<String, dynamic> _summarize(List<ui.FrameTiming> timings) {
  final buildDuration = _percentiles(
    timings.map((timing) => timing.buildDuration.inMicroseconds).toList(),
  );
  final rasterDuration = _percentiles(
    timings.map((timing) => timing.rasterDuration.inMicroseconds).toList(),
  );
  final totalSpan = _percentiles(
    timings.map((timing) => timing.totalSpan.inMicroseconds).toList(),
  );

  return {
    'buildDurationUs': buildDuration,
    'rasterDurationUs': rasterDuration,
    'totalSpanUs': totalSpan,
    'buildP95Pass': buildDuration['p95']! <= 16670,
    'rasterP95Pass': rasterDuration['p95']! <= 16670,
  };
}

Map<String, int> _percentiles(List<int> samples) {
  samples.sort();
  return {
    'p50': _percentile(samples, 0.50),
    'p90': _percentile(samples, 0.90),
    'p95': _percentile(samples, 0.95),
    'p99': _percentile(samples, 0.99),
  };
}

int _percentile(List<int> sortedSamples, double percentile) {
  final index = (sortedSamples.length * percentile).ceil() - 1;
  return sortedSamples[index.clamp(0, sortedSamples.length - 1).toInt()];
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 120; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  final visibleText = tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
      .where((text) => text.isNotEmpty)
      .join(' | ');
  // ignore: avoid_print
  print('T061 timeout waiting for $finder; visible text: $visibleText');
  expect(finder, findsOneWidget);
}

Future<void> _pumpAndSettleBounded(
  WidgetTester tester, {
  required String scenario,
  required String step,
}) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 3),
    );
  } on FlutterError catch (error) {
    throw TestFailure(
      'T061 scenario "$scenario" step "$step" did not settle within 3 seconds: '
      '$error',
    );
  }
}

Future<void> _runScenarioStep(
  String scenario,
  String step,
  Future<void> Function() action,
) async {
  _printScenarioStep(scenario, step, 'START');
  await action();
  _printScenarioStep(scenario, step, 'DONE');
}

void _printScenarioStep(String scenario, String step, String status) {
  // ignore: avoid_print
  print('T061 STEP [$scenario] $status: $step');
}

String _moduleTitle(String key) => switch (key) {
  'carbonFootprintTracker' => 'Carbon Footprint Tracker',
  'ecoFriendlyProductSuggestions' => 'Eco-Friendly Product Suggestions',
  'sustainableLivingChallenges' => 'Sustainable Living Challenges',
  'certificationsGuide' => 'Green Certifications & Labels Guide',
  'wasteReductionTracker' => 'Waste Reduction Tracker',
  'recipesMealPlanning' => 'Sustainable Recipes & Meal Planning',
  'energyConservationTips' => 'Energy Conservation Tips',
  'ecoTravelSuggestions' => 'Eco-Travel Suggestions',
  'communityJournal' => 'Community Journal',
  'progressDashboard' => 'Sustainability Progress Dashboard',
  'educationalContent' => 'Educational Content',
  _ => throw ArgumentError.value(key, 'key', 'Unknown module title key'),
};
