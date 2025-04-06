import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundify/soundify.dart';

/// Unit tests for different `SoundRules` in the Soundify package.
void main() {
  /// Test to ensure the swipe rule triggers when the swipe velocity is high enough.
  test('Swipe rule triggers with high velocity', () {
    final rule = SoundRules.swipe(minVelocity: 600.0);

    // Simulate a swipe gesture with high velocity
    final details = DragUpdateDetails(
      delta: const Offset(10, 0), // Simulated swipe movement
      globalPosition: Offset.zero,
      sourceTimeStamp: const Duration(milliseconds: 16), // Frame duration
    );

    // Assert that the rule should trigger for the simulated input
    expect(rule.shouldTrigger(null, details), true);
  });

  /// Test to ensure the shake rule triggers when a shake event is detected.
  test('Shake rule triggers on shake event', () {
    final rule = SoundRules.shake();

    // 'shake' is the event identifier for shake events
    expect(rule.shouldTrigger(null, 'shake'), true);
  });

  /// Test to ensure the tap rule triggers when a tap event occurs.
  test('Tap rule triggers on tap', () {
    final rule = SoundRules.tap();

    // TapDownDetails simulates a tap interaction
    expect(rule.shouldTrigger(null, TapDownDetails()), true);
  });

  /// Test to ensure the stateSuccess rule triggers when the 'success' state is passed.
  test('State success rule triggers on success', () {
    final rule = SoundRules.stateSuccess();

    // 'success' is the event identifier for a successful action
    expect(rule.shouldTrigger(null, 'success'), true);
  });

  /// Test to ensure the beep rule triggers when the 'beep' event is passed.
  test('Beep rule triggers on beep event', () {
    final rule = SoundRules.beep();

    // 'beep' is the event identifier for triggering a beep sound
    expect(rule.shouldTrigger(null, 'beep'), true);
  });
}
