# soundify

A powerful Flutter library for contextual audio and sensory feedback — enhance your app's accessibility and interactivity using intuitive sound cues and sensory responses.

## Features

- 🎯 **Contextual Audio Triggers** — Automatically respond to gestures, device motion, and state changes.
- 🔊 **Dynamic Tone Generation** — Create custom beeps and tones with adjustable frequency and duration.
- 🗣️ **Text-to-Speech** — Announce events using synthesized speech.
- 🤝 **Haptic Feedback Integration** — Combine sound with tactile feedback (where available).
- 🧠 **Customizable Rules** — Define when and how sounds should trigger.
- 🥇 **Sound Layering & Prioritization** — Manage overlapping audio cues with priorities.

## Getting Started

Add `soundify` to your `pubspec.yaml`:

```yaml
dependencies:
  soundify: ^0.1.0
```

## Usage

```dart
final soundify = Soundify(
  rules: [
    SoundRules.swipe(minVelocity: 600.0),
    SoundRules.shake(),
    SoundRules.tap(),
    SoundRules.stateSuccess(),
    SoundRules.announce(text: 'Action completed'),
    SoundRules.beep(frequency: 440.0),
  ],
);
void main() {
  SoundifyWrapper(
    soundify: soundify,
    child: Text('Swipe, Tap, or Shake Me!'),
  );
}
```

## Example

```dart
void main() {
ElevatedButton(
  onPressed: () => soundify.trigger(null, data: 'success'),
  child: const Text('Success'),
);
}
```

## Roadmap

- [ ] Rule chaining and condition building
- [ ] Custom audio asset support
- [ ] Advanced haptic configuration
- [ ] Web and desktop support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details — Contribute, fork, and enjoy!
