import 'package:flutter/widgets.dart';

abstract final class ReducedMotion {
  static bool isEnabled(BuildContext context, {bool? userOverride}) =>
      MediaQuery.disableAnimationsOf(context) || (userOverride ?? false);
}
