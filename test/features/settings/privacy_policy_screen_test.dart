import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/settings/presentation/privacy_policy_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('loads the offline privacy policy with readable sections', (
    tester,
  ) async {
    await tester.pumpWidget(const _TestApp(child: PrivacyPolicyScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Privacy policy'), findsOneWidget);
    expect(
      find.textContaining('Your data stays on this device'),
      findsOneWidget,
    );
    expect(find.textContaining('Export and deletion'), findsOneWidget);
    expect(
      find.textContaining(
        'The app does not send this information to a server.',
      ),
      findsOneWidget,
    );
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

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
  );
}
