import 'package:flutter/widgets.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../home/presentation/foundation_module_screen.dart';

class EcoFriendlyProductSuggestionsScreen extends StatelessWidget {
  const EcoFriendlyProductSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) => FoundationModuleScreen(
    title: AppLocalizations.of(context)!.ecoFriendlyProductSuggestions,
  );
}
