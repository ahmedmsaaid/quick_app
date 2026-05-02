import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../local_notification/local_notification_service.dart';

class PushNotificationService {
  static FirebaseMessaging message = FirebaseMessaging.instance;
  static Future<void> init() async {
    await message.requestPermission();
    String? token = await message.getToken();
    log("firebase token   ${token ?? "no token"}");
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotificationService.showBasicNotification(message);
    });
  }

  @pragma('vm:entry-point')
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    log("handleBackgroundMessage ${message.notification?.title}");
  }
}

/*
  1. permission
  2. fcm token
  3. background message
  4. foreground message
  5. kill app message
  6. test message with postman
  7. sent image with message
  9.send token to server

 */
