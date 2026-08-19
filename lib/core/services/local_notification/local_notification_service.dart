import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:base_app/core/services/audio/order_sound_service.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<NotificationResponse> streamController =
      StreamController<NotificationResponse>.broadcast();

  /// Called when the user taps the notification
  @pragma('vm:entry-point')
  static void onTap(NotificationResponse notificationResponse) {
    OrderSoundService.stopRingtone();
    streamController.add(notificationResponse);
  }

  /// Initialization for Android & iOS
  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
    );
  }

  /// Show High Importance Delivery Order Notification with Loud Ringtone
  static Future<void> showDeliveryOrderNotification(RemoteMessage message) async {
    try {
      // 1. Play loud ringtone sound in loop
      await OrderSoundService.playOrderRingtone();

      final AndroidNotificationDetails android = AndroidNotificationDetails(
        'delivery_order_ringtone_channel_v2',
        'Delivery Order Ringtone Channel',
        channelDescription: 'Loud alarm ringtone notifications for delivery captain orders',
        importance: Importance.max,
        priority: Priority.high,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
      );

      const DarwinNotificationDetails ios = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      );

      final NotificationDetails details = NotificationDetails(android: android, iOS: ios);

      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title ?? 'طلب دليفري جديد 🚴',
        message.notification?.body ?? 'وصلك طلب دليفري جديد، انقر لمشاهدة التفاصيل',
        details,
        payload: message.data['route'] ?? 'captain',
      );
    } catch (e) {
      log("❌ Error showing delivery order notification: $e");
    }
  }

  /// Show Notification (basic + image if exists)
  static Future<void> showBasicNotification(RemoteMessage message) async {
    try {
      final imageUrl = message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl ??
          '';

      BigPictureStyleInformation? bigPictureStyleInformation;

      if (imageUrl.isNotEmpty) {
        final String filePath = await _downloadAndSaveFile(
          imageUrl,
          'bigPicture.jpg',
        );

        bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(filePath),
          largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
          contentTitle: message.notification?.title,
          summaryText: message.notification?.body,
          hideExpandedLargeIcon: false,
        );
      }

      final AndroidNotificationDetails android = AndroidNotificationDetails(
        'id_1',
        'basic_notification',
        channelDescription: 'Basic notification channel',
        importance: Importance.max,
        priority: Priority.high,
        // Always show the app icon as the large icon on the right
        largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
        styleInformation: bigPictureStyleInformation,
      );

      final NotificationDetails details = NotificationDetails(android: android);

      // Use hashCode for unique ID so multiple notifications don't overwrite each other
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        details,
        payload: message.data['route'] ?? 'notifications',
      );
    } catch (e) {
      log("❌ Error showing notification: $e");
    }
  }


  /// Helper: download image using Dio and save locally
  static Future<String> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';

    final Response<List<int>> response = await Dio().get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    final File file = File(filePath);
    await file.writeAsBytes(response.data!);
    return filePath;
  }
}
