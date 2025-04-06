import 'package:flutter/material.dart';
import 'package:soundify/soundify.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// Root widget of the Soundify demo application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a Soundify instance with predefined rules.
    final soundify = Soundify(
      rules: [
        SoundRules.swipe(minVelocity: 600.0), // Plays on swipe with velocity
        SoundRules.shake(), // Plays on device shake
        SoundRules.tap(), // Plays on tap
        SoundRules.stateSuccess(), // Plays on 'success' state
        SoundRules.announce(text: 'Action completed'), // Speaks a message
        SoundRules.beep(frequency: 440.0), // Beeps on 'beep' event
      ],
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Soundify Demo')),
        body: SoundifyWrapper(
          soundify: soundify,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Swipe, Tap, or Shake Me!'),

                /// Button that triggers the 'success' rule.
                ElevatedButton(
                  onPressed: () => soundify.trigger(null, data: 'success'),
                  child: const Text('Success'),
                ),

                /// Button that triggers the 'beep' rule.
                ElevatedButton(
                  onPressed: () => soundify.trigger(null, data: 'beep'),
                  child: const Text('Beep'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
