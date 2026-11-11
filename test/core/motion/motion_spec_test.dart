import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/motion/motion_spec.dart';

void main() {
  test('centralizes instant changes and optional 120 ms fades', () {
    expect(MotionSpec.instant, Duration.zero);
    expect(MotionSpec.optionalFade, const Duration(milliseconds: 120));
    expect(MotionSpec.optionalFadeCurve, Curves.linear);
    expect(MotionSpec.numberTickCurve, Curves.linear);
    expect(
      MotionSpec.duration(false, MotionSpec.optionalFade),
      MotionSpec.optionalFade,
    );
    expect(MotionSpec.duration(true, MotionSpec.optionalFade), Duration.zero);
  });

  group('MotionSpec.spring', () {
    test('retargets from the requested current position', () {
      final simulation = MotionSpec.spring(start: 0.25, end: 1, velocity: 0);

      expect(simulation.x(0), closeTo(0.25, 1e-9));
      expect(simulation.x(0.1), isNot(closeTo(0.25, 1e-3)));
      expect(simulation.x(0.1), lessThan(1));
    });

    test('preserves velocity when handing off to a new spring', () {
      const velocity = 2.4;
      final simulation = MotionSpec.spring(
        start: 0,
        end: 1,
        velocity: velocity,
      );

      expect(simulation, isA<SpringSimulation>());
      expect(simulation.dx(0), closeTo(velocity, 1e-9));
    });

    test('can be interrupted and retargeted from its current state', () {
      final first = MotionSpec.spring(start: 0, end: 1, velocity: 0);
      const interruptedAt = 0.18;
      final position = first.x(interruptedAt);
      final velocity = first.dx(interruptedAt);

      final second = MotionSpec.spring(
        start: position,
        end: -0.5,
        velocity: velocity,
      );

      expect(second.x(0), closeTo(position, 1e-9));
      expect(second.dx(0), closeTo(velocity, 1e-9));
    });

    test('reduced motion resolves immediately at the target', () {
      final simulation = MotionSpec.spring(
        start: 0,
        end: 1,
        velocity: 3,
        reducedMotion: true,
      );

      expect(simulation.x(0), 1);
      expect(simulation.dx(0), 0);
    });

    test('settles without overshoot for a state change', () {
      final simulation = MotionSpec.spring(start: 0, end: 1, velocity: 0);
      var previous = simulation.x(0);

      for (var milliseconds = 10; milliseconds <= 2000; milliseconds += 10) {
        final value = simulation.x(milliseconds / 1000);
        expect(value, greaterThanOrEqualTo(previous));
        expect(value, lessThanOrEqualTo(1));
        previous = value;
      }
    });
  });
}
