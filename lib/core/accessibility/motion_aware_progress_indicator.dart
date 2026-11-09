import 'package:flutter/material.dart';

import 'reduced_motion.dart';

class MotionAwareProgressIndicator extends StatelessWidget {
  const MotionAwareProgressIndicator({
    required this.semanticsLabel,
    this.size = 36,
    this.strokeWidth = 4,
    super.key,
  });

  final String semanticsLabel;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    if (ReducedMotion.isEnabled(context)) {
      return Semantics(
        container: true,
        label: semanticsLabel,
        liveRegion: true,
        child: ExcludeSemantics(
          child: SizedBox(
            width: size,
            height: size,
            child: const Icon(Icons.hourglass_empty),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        semanticsLabel: semanticsLabel,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
