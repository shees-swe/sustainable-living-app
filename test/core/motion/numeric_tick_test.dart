import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/motion/numeric_tick.dart';

void main() {
  testWidgets('counts linearly to its exact destination in 120 ms', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NumericTick(
            value: 42.5,
            decimalPlaces: 1,
            style: TextStyle(fontFamily: 'IBMPlexMono'),
          ),
        ),
      ),
    );

    expect(find.text('0.0'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('42.5'), findsOneWidget);
  });

  testWidgets(
    'shows the destination immediately when animations are disabled',
    (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: NumericTick(
                value: 42.5,
                decimalPlaces: 1,
                style: TextStyle(fontFamily: 'IBMPlexMono'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('42.5'), findsOneWidget);
    },
  );

  testWidgets('does not block actions while the number is counting', (
    tester,
  ) async {
    var actionTriggered = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const NumericTick(
                value: 42.5,
                decimalPlaces: 1,
                style: TextStyle(fontFamily: 'IBMPlexMono'),
              ),
              TextButton(
                onPressed: () => actionTriggered = true,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Continue'));
    expect(actionTriggered, isTrue);
  });
}
