import 'package:flutter/widgets.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../home/presentation/foundation_module_screen.dart';

class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => FoundationModuleScreen(
    title: AppLocalizations.of(context)!.progressDashboard,
  );
}
