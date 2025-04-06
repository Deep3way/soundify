/// A library for managing audio and haptic feedback in response to user interactions.
library soundify;

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Core class for managing audio and sensory feedback.
class Soundify {
  final List<AudioPlayer> _players = [AudioPlayer(), AudioPlayer()];
  final FlutterTts _tts = FlutterTts();
  final List<SoundRule> rules;
  StreamSubscription? _accelerometerSubscription;

  /// Constructs a [Soundify] instance with a list of [SoundRule]s.
  ///
  /// Automatically listens for shake gestures using accelerometer.
  Soundify({required this.rules}) {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (event.x.abs() > 15 || event.y.abs() > 15 || event.z.abs() > 15) {
        trigger(null, data: 'shake');
      }
    });
    _tts.setLanguage('en-US');
  }

  /// Triggers audio and haptic feedback based on the provided [data] and optional [context].
  void trigger(BuildContext? context, {dynamic data}) {
    for (var rule in rules) {
      if (rule.shouldTrigger(context, data)) {
        if (rule is VoiceRule) {
          _tts.speak(rule.text);
        } else if (rule is DynamicToneRule) {
          _playDynamicTone(rule.frequency, rule.duration);
        } else {
          final player = _players[rule.priority % _players.length];
          player
            ..setVolume(rule.volume)
            ..setPlaybackRate(rule.pitch)
            ..play(AssetSource(rule.audioPath));
        }
        if (rule.hapticType != null) {
          Haptics.vibrate(rule.hapticType!);
        }
        if (!rule.allowLayering) break;
      }
    }
  }

  /// Plays a dynamically generated tone at the given [frequency] and [durationMs].
  void _playDynamicTone(double frequency, int durationMs) {
    final player = _players[0];
    player.play(BytesSource(_generateSineWave(frequency, durationMs)));
  }

  /// Generates a sine wave tone as PCM byte data.
  Uint8List _generateSineWave(double frequency, int durationMs) {
    const sampleRate = 44100;
    final samples = (sampleRate * durationMs / 1000).round();
    final buffer = Uint8List(samples * 2);
    for (int i = 0; i < samples; i++) {
      final sample =
          (math.sin(2 * math.pi * frequency * i / sampleRate) * 32767).round();
      buffer[i * 2] = sample & 0xFF;
      buffer[i * 2 + 1] = (sample >> 8) & 0xFF;
    }
    return buffer;
  }

  /// Cleans up resources and subscriptions.
  void dispose() {
    for (var player in _players) {
      player.dispose();
    }
    _accelerometerSubscription?.cancel();
    _tts.stop();
  }
}

/// Abstract base class for defining sound rules.
abstract class SoundRule {
  final String audioPath;
  final double volume;
  final double pitch;
  final int priority;
  final bool allowLayering;
  final HapticsType? hapticType;
  final bool Function(BuildContext? context, dynamic data) condition;

  /// Constructs a [SoundRule] with playback and condition configurations.
  SoundRule({
    required this.audioPath,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.priority = 0,
    this.allowLayering = false,
    this.hapticType,
    required this.condition,
  });

  /// Evaluates whether this rule should be triggered.
  bool shouldTrigger(BuildContext? context, dynamic data);
}

/// A sound rule for playing static audio clips.
class AudioRule extends SoundRule {
  AudioRule({
    required String audioPath,
    double volume = 1.0,
    double pitch = 1.0,
    int priority = 0,
    bool allowLayering = false,
    HapticsType? hapticType,
    required bool Function(BuildContext? context, dynamic data) condition,
  }) : super(
          audioPath: audioPath,
          volume: volume,
          pitch: pitch,
          priority: priority,
          allowLayering: allowLayering,
          hapticType: hapticType,
          condition: condition,
        );

  @override
  bool shouldTrigger(BuildContext? context, dynamic data) =>
      condition(context, data);
}

/// A sound rule for text-to-speech feedback.
class VoiceRule extends SoundRule {
  /// The text to be spoken.
  final String text;

  VoiceRule({
    required this.text,
    HapticsType? hapticType,
  }) : super(
          audioPath: '',
          hapticType: hapticType,
          condition: (context, data) => true,
        );

  @override
  bool shouldTrigger(BuildContext? context, dynamic data) =>
      condition(context, data);
}

/// A sound rule that generates and plays a tone dynamically.
class DynamicToneRule extends SoundRule {
  /// Frequency in Hertz.
  final double frequency;

  /// Duration in milliseconds.
  final int duration;

  DynamicToneRule({
    required this.frequency,
    required this.duration,
    HapticsType? hapticType,
    required bool Function(BuildContext? context, dynamic data) condition,
  }) : super(
          audioPath: '',
          hapticType: hapticType,
          condition: condition,
        );

  @override
  bool shouldTrigger(BuildContext? context, dynamic data) =>
      condition(context, data);
}

/// Provides commonly used [SoundRule] configurations.
class SoundRules {
  /// A rule triggered on horizontal swipe with minimum velocity.
  static AudioRule swipe({
    String audioPath = 'swipe.mp3',
    double minVelocity = 500.0,
  }) {
    return AudioRule(
      audioPath: audioPath,
      volume: 0.8,
      pitch: 1.0 + (minVelocity / 1000.0),
      hapticType: HapticsType.light,
      condition: (context, data) {
        if (data is DragUpdateDetails) {
          final velocity = data.delta.distance / 0.016;
          return velocity >= minVelocity;
        }
        return false;
      },
    );
  }

  /// A rule triggered on shake gesture.
  static AudioRule shake({String audioPath = 'shake.mp3'}) {
    return AudioRule(
      audioPath: audioPath,
      volume: 1.0,
      pitch: 1.2,
      hapticType: HapticsType.heavy,
      condition: (context, data) => data == 'shake',
    );
  }

  /// A rule triggered on tap interaction.
  static AudioRule tap({String audioPath = 'click.mp3'}) {
    return AudioRule(
      audioPath: audioPath,
      volume: 0.7,
      pitch: 1.0,
      hapticType: HapticsType.selection,
      condition: (context, data) => data == null || data is TapDownDetails,
    );
  }

  /// A rule triggered for success state feedback.
  static AudioRule stateSuccess({String audioPath = 'success.mp3'}) {
    return AudioRule(
      audioPath: audioPath,
      volume: 0.9,
      pitch: 1.0,
      hapticType: HapticsType.medium,
      condition: (context, data) => data == 'success',
    );
  }

  /// A rule for announcing spoken messages.
  static VoiceRule announce({required String text}) {
    return VoiceRule(text: text, hapticType: HapticsType.light);
  }

  /// A rule that emits a short dynamic beep tone.
  static DynamicToneRule beep({
    double frequency = 440.0,
    int duration = 200,
  }) {
    return DynamicToneRule(
      frequency: frequency,
      duration: duration,
      hapticType: HapticsType.light,
      condition: (context, data) => data == 'beep',
    );
  }
}

/// A widget that wraps UI and integrates [Soundify] with gesture detection.
class SoundifyWrapper extends StatelessWidget {
  /// The [Soundify] instance to trigger feedback.
  final Soundify soundify;

  /// The wrapped child widget.
  final Widget child;

  const SoundifyWrapper({
    super.key,
    required this.soundify,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) =>
          soundify.trigger(context, data: details),
      onTapDown: (details) => soundify.trigger(context, data: details),
      child: child,
    );
  }
}
