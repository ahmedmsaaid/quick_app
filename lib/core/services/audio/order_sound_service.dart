import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';

class OrderSoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;

  /// Plays a loud ringtone sound for new delivery orders.
  /// Uses AudioContext with AndroidUsageType.alarm and AVAudioSessionCategory.playback
  /// so that the sound plays out loud even if the device is set to silent or vibrate.
  static Future<void> playOrderRingtone() async {
    try {
      log("🔔 [OrderSoundService] Playing delivery order ringtone...");

      // Set audio context to ALARM / RINGTONE channel to bypass silent mode
      await _audioPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ),
      );

      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Play local asset ringtone
      await _audioPlayer.play(
        AssetSource('audio/order_ringtone.mp3'),
      );
      _isPlaying = true;
    } catch (e) {
      log("⚠️ [OrderSoundService] Error playing order ringtone: $e");
    }
  }

  /// Stops the ringtone when captain interacts or opens notifications/orders.
  static Future<void> stopRingtone() async {
    try {
      if (_isPlaying) {
        log("🔇 [OrderSoundService] Stopping ringtone...");
        await _audioPlayer.stop();
        _isPlaying = false;
      }
    } catch (e) {
      log("⚠️ [OrderSoundService] Error stopping ringtone: $e");
    }
  }

  static bool get isPlaying => _isPlaying;
}
