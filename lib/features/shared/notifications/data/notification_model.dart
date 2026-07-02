// lib/features/shared/notifications/data/notification_model.dart

import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';

class NotificationDto {
  final int id;
  final int? entityId;
  final int? entityType;
  final String? title;
  final String? body;
  final String? imageUrl;
  final bool isRead;
  final DateTime? createdOn;
  final int? creatorId;

  const NotificationDto({
    required this.id,
    this.entityId,
    this.entityType,
    this.title,
    this.body,
    this.imageUrl,
    required this.isRead,
    this.createdOn,
    this.creatorId,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    // Read current app language from cache (default to Arabic)
    final lang = CacheHelper.getString(CacheKeys.lang) ?? 'ar';

    // recipientMessage and creatorMessage are localized objects {ar: ..., en: ...}
    final recipientMsg = json['recipientMessage'] is Map
        ? json['recipientMessage'] as Map<String, dynamic>
        : null;
    final creatorMsg = json['creatorMessage'] is Map
        ? json['creatorMessage'] as Map<String, dynamic>
        : null;

    // Body: prefer recipientMessage in current lang, fallback to ar, then other fields
    final localizedBody =
        recipientMsg?[lang] as String? ??
        recipientMsg?['ar'] as String? ??
        creatorMsg?[lang] as String? ??
        creatorMsg?['ar'] as String? ??
        json['body'] as String? ??
        json['content'] as String?;

    // Title: from creatorMessage (describes the action)
    final localizedTitle =
        json['title'] as String? ??
        creatorMsg?[lang] as String? ??
        creatorMsg?['ar'] as String?;

    // Avatar from nested creator object
    final creator = json['creator'] is Map
        ? json['creator'] as Map<String, dynamic>
        : null;
    final creatorPhoto =
        creator?['photo'] as String? ??
        creator?['avatar'] as String? ??
        json['imageUrl'] as String?;

    return NotificationDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      entityId: json['entityId'] as int?,
      entityType: json['entityType'] as int?,
      title: localizedTitle,
      body: localizedBody,
      imageUrl: creatorPhoto,
      isRead: json['read'] as bool? ?? json['isRead'] as bool? ?? false,
      createdOn: json['createdOn'] != null
          ? DateTime.tryParse(json['createdOn'] as String)
          : null,
      creatorId: json['creatorId'] as int?,
    );
  }
}
