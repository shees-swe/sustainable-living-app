import 'dart:async';

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

abstract final class MotionSpec {
  static const Duration instant = Duration.zero;
  static const Duration optionalFade = Duration(milliseconds: 120);
  static const Curve optionalFadeCurve = Curves.linear;
  static const Curve numberTickCurve = Curves.linear;

  static Duration duration(bool reducedMotion, Duration duration) =>
      reducedMotion ? instant : duration;

  static final SpringDescription standardSpring = SpringDescription(
    mass: 1,
    stiffness: 220,
    damping: 32,
  );

  static SpringSimulation spring({
    required double start,
    required double end,
    required double velocity,
    bool reducedMotion = false,
  }) {
    if (reducedMotion) {
      return SpringSimulation(standardSpring, end, end, 0);
    }

    return SpringSimulation(standardSpring, start, end, velocity);
  }
}

class SpringMotionController {
  SpringMotionController({required TickerProvider vsync, double value = 0})
    : controller = AnimationController(vsync: vsync, value: value);

  final AnimationController controller;
  bool _disposed = false;

  void retarget(double target, {bool reducedMotion = false}) {
    if (_disposed) {
      return;
    }

    if (reducedMotion) {
      controller.stop();
      controller.value = target;
      return;
    }

    unawaited(
      controller.animateWith(
        MotionSpec.spring(
          start: controller.value,
          end: target,
          velocity: controller.velocity,
        ),
      ),
    );
  }

  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    controller.dispose();
  }
}
