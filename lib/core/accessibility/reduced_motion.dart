import 'package:flutter/widgets.dart';

abstract final class ReducedMotion {
  static bool isEnabled(BuildContext context, {bool? userOverride}) =>
      MediaQuery.disableAnimationsOf(context) || (userOverride ?? false);

  static Duration duration(BuildContext context, Duration duration) =>
      isEnabled(context) ? Duration.zero : duration;
}
