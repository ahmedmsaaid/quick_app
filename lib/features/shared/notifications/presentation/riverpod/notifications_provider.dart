// lib/features/shared/notifications/presentation/riverpod/notifications_provider.dart

import 'package:base_app/core/network/api_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/features/shared/notifications/data/notification_model.dart';
import 'package:base_app/features/shared/notifications/data/notifications_api_service.dart';

part 'notifications_provider.g.dart';

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState {
  final NotificationsStatus status;
  final List<NotificationDto> notifications;
  final int unreadCount;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationDto>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
        unreadCount: unreadCount ?? this.unreadCount,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

@Riverpod(keepAlive: true)
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  NotificationsState build() => const NotificationsState();

  /// Fetch paginated notifications list and unread count together.
  Future<void> fetchNotifications() async {
    state = state.copyWith(status: NotificationsStatus.loading);

    final service = ref.read(notificationsApiServiceProvider);

    final listResult = await service.getNotifications();
    final countResult = await service.countNotifications();

    List<NotificationDto> notifications = state.notifications;
    int unreadCount = state.unreadCount;
    String? error;

    // Handle list result
    listResult.when(
      success: (response) {
        if (response.success && response.result != null) {
          notifications = response.result!;
        } else {
          error = response.message;
        }
      },
      failure: (failure) {
        error = failure.message;
      },
    );

    // Handle count result (best-effort — don't overwrite error from list)
    countResult.when(
      success: (response) {
        if (response.success && response.result != null) {
          unreadCount = response.result!;
        }
      },
      failure: (_) {},
    );

    state = state.copyWith(
      status: error == null
          ? NotificationsStatus.loaded
          : NotificationsStatus.error,
      notifications: notifications,
      unreadCount: unreadCount,
      errorMessage: error,
    );
  }

  /// Fetch only the unread count (lightweight — called from header bell icon).
  Future<void> fetchUnreadCount() async {
    final service = ref.read(notificationsApiServiceProvider);
    final result = await service.countNotifications();
    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = state.copyWith(unreadCount: response.result!);
        }
      },
      failure: (_) {},
    );
  }

  /// Mark a single notification as read and refresh the count.
  Future<void> markAsRead(int auditId) async {
    final service = ref.read(notificationsApiServiceProvider);
    await service.readNotification(auditId);

    // Optimistically update local state
    final updated = state.notifications.map((n) {
      if (n.id == auditId) {
        return NotificationDto(
          id: n.id,
          entityId: n.entityId,
          entityType: n.entityType,
          title: n.title,
          body: n.body,
          imageUrl: n.imageUrl,
          isRead: true,
          createdOn: n.createdOn,
          creatorId: n.creatorId,
        );
      }
      return n;
    }).toList();

    final newUnread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: newUnread);
  }
}
