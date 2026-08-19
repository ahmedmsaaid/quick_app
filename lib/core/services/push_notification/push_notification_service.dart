import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';
import 'package:base_app/core/services/local_notification/local_notification_service.dart';
import 'package:base_app/core/services/audio/order_sound_service.dart';
import 'package:base_app/main.dart'; // to get navigatorKey
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_orders_provider.dart';
import 'package:base_app/features/shared/notifications/presentation/riverpod/notifications_provider.dart';
import 'package:base_app/features/shared/chat/presentation/riverpod/app_chat_grbc_notifier.dart';

class PushNotificationService {
  final Ref _ref;
  StreamSubscription<String>? _tokenRefreshSub;

  PushNotificationService(this._ref);

  Future<void> init() async {
    log("🔔 Initializing Push Notification Service...");
    
    // 1. Request permissions
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialize Local Notifications
    await LocalNotificationService.init();

    // 3. Listen to local notification taps
    LocalNotificationService.streamController.stream.listen((response) {
      log("🔔 Local notification tapped: ${response.payload}");
      _openNotificationScreen();
    });

    // 4. Background message handler
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // 5. Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("🔔 Foreground notification received: ${message.notification?.title}");

      final role = CacheHelper.getInt('userRole') ?? 2;
      final bool isOrderPush = message.data['type'] == 'order' ||
          message.data['type'] == 'new_order' ||
          message.data['orderId'] != null ||
          (message.notification?.title?.contains('طلب') ?? false) ||
          (message.notification?.title?.contains('اوردر') ?? false) ||
          (message.notification?.body?.contains('طلب') ?? false) ||
          (message.notification?.body?.contains('اوردر') ?? false);

      if (role == 3 || isOrderPush) {
        LocalNotificationService.showDeliveryOrderNotification(message);
      } else {
        LocalNotificationService.showBasicNotification(message);
      }
      
      // Update unread count for notifications badge
      _ref.read(notificationsProvider.notifier).fetchUnreadCount();
      
      if (role == 3) {
        log("🔄 Refreshing captain orders list on foreground notification");
        _ref.read(captainOrdersProvider.notifier).loadAll();
      }

      // Check if this is a chat message and trigger real-time chat details refresh if active
      final isChat = message.data['chatId'] != null ||
          message.data['type'] == 'chat' ||
          message.data['click_action'] == 'chat' ||
          (message.notification?.title?.contains('رسالة') ?? false) ||
          (message.notification?.title?.contains('محادثة') ?? false) ||
          (message.notification?.body?.contains('شات') ?? false);

      if (isChat) {
        try {
          log("💬 Chat message received in foreground. Syncing chat view...");
          _ref.read(appChatGrbcProvider.notifier).refreshFromPush();
        } catch (e) {
          log("⚠️ Error refreshing chat from foreground notification: $e");
        }
      }
    });

    // 6. Background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("🔔 Background notification tapped: ${message.notification?.title}");
      OrderSoundService.stopRingtone();
      _openNotificationScreen();
      
      // Update unread count for notifications badge
      _ref.read(notificationsProvider.notifier).fetchUnreadCount();
      
      final role = CacheHelper.getInt('userRole') ?? 2;
      if (role == 3) {
        log("🔄 Refreshing captain orders list on background notification tap");
        _ref.read(captainOrdersProvider.notifier).loadAll();
      }
    });

    // 7. Terminated app launch from notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      log("🔔 Terminated notification launch: ${initialMessage.notification?.title}");
      OrderSoundService.stopRingtone();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openNotificationScreen();
      });
    }

    // 8. Start listening to token refresh
    _startListeningRefresh();
  }

  void _openNotificationScreen() {
    OrderSoundService.stopRingtone();
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    final currentRoute = ModalRoute.of(navigator.context)?.settings.name;
    if (currentRoute == AppRoutes.notifications) return;
    navigator.pushNamed(AppRoutes.notifications);
  }

  @pragma('vm:entry-point')
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    log("🔔 Handle background message: ${message.notification?.title}");
    await LocalNotificationService.showDeliveryOrderNotification(message);
  }

  Future<bool> registerDeviceTokenWithBackend() async {
    final token = CacheHelper.getString(CacheKeys.token);
    if (token == null || token.isEmpty) {
      log("ℹ️ No active user session, skipping FCM token registration");
      return false;
    }

    String? fcmToken;
    try {
      if (Platform.isIOS) {
        for (int i = 0; i < 10; i++) {
          final apns = await FirebaseMessaging.instance.getAPNSToken();
          if (apns != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      log("❌ Error getting FCM token: $e");
      return false;
    }

    if (fcmToken == null) {
      log("❌ FCM token is null");
      return false;
    }

    log("🔄 Registering FCM Token with backend: $fcmToken");
    final dio = _ref.read(dioProvider);

    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await dio.post(
          'users/add-fcm-token',
          data: {'token': fcmToken},
        );
        final success = response.data['success'] as bool? ?? false;
        if (success) {
          log("✅ FCM Token registered successfully!");
          return true;
        }
      } catch (e) {
        log("❌ Attempt ${attempt + 1} failed to register FCM token: $e");
      }
      await Future.delayed(Duration(seconds: 1 << attempt));
    }
    return false;
  }

  void _startListeningRefresh() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      registerDeviceTokenWithBackend();
    });
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final service = PushNotificationService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
