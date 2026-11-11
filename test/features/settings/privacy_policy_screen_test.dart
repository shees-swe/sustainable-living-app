import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/settings/presentation/privacy_policy_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  testWidgets('privacy policy remains readable at Very Large text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(textScale: 2, child: PrivacyPolicyScreen()),
    );
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(ListView).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.byType(ListView), findsOneWidget);
    await _scrollUntilTextVisible(
      tester,
      findTextContaining('Your data stays on this device'),
      'Your data stays on this device',
    );
    expect(
      findTextContaining('Your data stays on this device'),
      findsOneWidget,
    );
    expectNoTextOverlapOrClipping(tester, 'Privacy policy');
    for (final section in [
      'The app does not send this information to a server.',
      'Export and deletion',
      'It cannot guarantee forensic erasure',
      'You are responsible for deleting any copies',
    ]) {
      final sectionText = findTextContaining(section);
      await _scrollUntilTextVisible(tester, sectionText, section);
      expect(sectionText, findsOneWidget);
      expectNoTextOverlapOrClipping(tester, 'Privacy policy: $section');
    }
    expect(tester.takeException(), isNull);
  });
}

Future<void> _scrollUntilTextVisible(
  WidgetTester tester,
  Finder target,
  String label,
) async {
  final viewport = find.byType(ListView).first;
  for (var attempt = 0; attempt < 20; attempt++) {
    if (target.evaluate().isNotEmpty &&
        tester.getRect(target.first).overlaps(tester.getRect(viewport))) {
      return;
    }
    await tester.drag(viewport, const Offset(0, -240));
    await tester.pump();
  }
  final position = tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position;
  fail(
    'Text did not become visible: $label; '
    'scroll=${position.pixels}, max=${position.maxScrollExtent}, '
    'matches=${target.evaluate().length}',
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScale = 1});

  final Widget child;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: child,
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
  );
}
