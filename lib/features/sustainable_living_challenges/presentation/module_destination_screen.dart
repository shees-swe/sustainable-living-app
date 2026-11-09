import 'package:flutter/widgets.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../home/presentation/foundation_module_screen.dart';

class SustainableLivingChallengesScreen extends StatelessWidget {
  const SustainableLivingChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) => FoundationModuleScreen(
    title: AppLocalizations.of(context)!.sustainableLivingChallenges,
  );
}
