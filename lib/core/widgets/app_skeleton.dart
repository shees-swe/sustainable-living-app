import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../theme/app_theme.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({required this.semanticsLabel, super.key});

  final String semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticsLabel,
    liveRegion: true,
    child: ExcludeSemantics(
      child: Skeletonizer(
        effect: const SolidColorEffect(color: ClimateColors.surfaceSecondary),
        enableSwitchAnimation: false,
        child: const SizedBox(
          width: 280,
          child: Text(
            'Estimate result\n'
            '000.00 kg CO2e/year\n\n'
            'Lifestyle budget share\n'
            'At least 00.0% of the 1.5° budget',
          ),
        ),
      ),
    ),
  );
}
