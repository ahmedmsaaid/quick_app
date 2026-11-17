import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';

class OrderSoundService {
  static final AudioPlayer _audioPlayer =
      AudioPlayer(playerId: 'delivery_order_ringtone_player');
  static bool _isPlaying = false;
  static Timer? _autoStopTimer;

  /// Plays a loud ringtone sound for new delivery orders (Captain role == 3 only).
  /// Uses AudioContext with AndroidUsageType.alarm and AVAudioSessionCategory.playback
  /// so that the sound plays out loud even if the device is set to silent or vibrate.
  static Future<void> playOrderRingtone() async {
    try {
      final role = CacheHelper.getInt('userRole') ?? 2;
      if (role != 3) {
        log("ℹ️ [OrderSoundService] Skipping delivery ringtone for non-captain role ($role).");
        return;
      }

      log("🔔 [OrderSoundService] Playing delivery order ringtone...");

      _autoStopTimer?.cancel();

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

      // Auto-stop after 30 seconds as safety net so it doesn't ring indefinitely
      _autoStopTimer = Timer(const Duration(seconds: 30), () {
        log("⏱️ [OrderSoundService] Auto-stopping ringtone after 30s timeout...");
        stopRingtone();
      });
    } catch (e) {
      log("⚠️ [OrderSoundService] Error playing order ringtone: $e");
    }
  }

  /// Stops the ringtone when captain interacts or opens notifications/orders.
  static Future<void> stopRingtone() async {
    try {
      _autoStopTimer?.cancel();
      _autoStopTimer = null;
      _isPlaying = false;
      log("🔇 [OrderSoundService] Stopping ringtone...");
      await _audioPlayer.stop();
    } catch (e) {
      log("⚠️ [OrderSoundService] Error stopping ringtone: $e");
    }
  }

  static bool get isPlaying => _isPlaying;
}
