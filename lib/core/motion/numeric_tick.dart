import 'package:flutter/material.dart';

import '../accessibility/reduced_motion.dart';
import 'motion_spec.dart';

class NumericTick extends StatelessWidget {
  const NumericTick({
    required this.value,
    required this.style,
    this.decimalPlaces = 0,
    this.suffix,
    this.suffixStyle,
    this.textKey,
    super.key,
  });

  final double value;
  final TextStyle style;
  final int decimalPlaces;
  final String? suffix;
  final TextStyle? suffixStyle;
  final Key? textKey;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: value),
    duration: ReducedMotion.duration(context, MotionSpec.optionalFade),
    curve: MotionSpec.numberTickCurve,
    builder: (context, currentValue, _) {
      final formatted = currentValue.toStringAsFixed(decimalPlaces);
      if (suffix == null) {
        return Text(formatted, key: textKey, style: style);
      }
      return Text.rich(
        key: textKey,
        TextSpan(
          children: [
            TextSpan(text: formatted, style: style),
            TextSpan(text: suffix, style: suffixStyle),
          ],
        ),
      );
    },
  );
}
