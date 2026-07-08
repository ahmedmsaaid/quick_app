import 'package:base_app/features/shared/chat/data/models/app_chat_default_models/get_all_chats_result_response.dart';

import 'package:base_app/core/exports/exports.dart';
import 'package:base_app/core/utils/format_date.dart';
import 'package:base_app/core/widgets/cached_network_image.dart';
import 'package:base_app/core/network/api_constants.dart';

class ChatItemWidget extends StatelessWidget {
  const ChatItemWidget({
    super.key,
    required this.item,
    this.onTap,
    required this.isCreator,
  });

  final GetAllChatsResultResponse item;
  final Function()? onTap;
  final bool isCreator;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve the other party's data
    final other = isCreator ? item.creator : item.participant;
    final rawPhoto = other?.photo ?? other?.avatar;
    final photoUrl = (rawPhoto != null && rawPhoto.isNotEmpty)
        ? (rawPhoto.startsWith('http')
            ? rawPhoto
            : '${ApiConstants.streamUrl}$rawPhoto')
        : '';

    final name = other?.name ?? '';
    final lastMessage = item.message?.content ?? '';
    final hasMedia =
        (item.message?.mediaUrl ?? '').isNotEmpty;
    final timeStr = item.createdOn != null
        ? formatDateChatPMAM(DateTime.parse(item.createdOn!))
        : '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? colors.border.withValues(alpha: 0.5)
                  : colors.border.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Avatar ──────────────────────────────────────
              Stack(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: photoUrl.isNotEmpty
                          ? CustomNetworkImage.circular(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              radius: 52,
                            )
                          : Container(
                              color: colors.primary.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.person_rounded,
                                color: colors.primary,
                                size: 28.sp,
                              ),
                            ),
                    ),
                  ),
                  // Online dot / chat indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                      child: Icon(
                        Icons.chat_rounded,
                        color: Colors.white,
                        size: 8.sp,
                      ),
                    ),
                  ),
                ],
              ),

              12.horizontalSpace,

              // ── Name + Last message ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.text15w700(color: colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.verticalSpace,
                    hasMedia
                        ? Row(
                            children: [
                              Icon(
                                Icons.image_rounded,
                                size: 14.sp,
                                color: colors.textSecondary,
                              ),
                              4.horizontalSpace,
                              Text(
                                'صورة',
                                style: AppTextStyles.text12w400(
                                    color: colors.textSecondary),
                              ),
                            ],
                          )
                        : Text(
                            lastMessage,
                            style: AppTextStyles.text12w400(
                                color: colors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ],
                ),
              ),

              8.horizontalSpace,

              // ── Time ────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: AppTextStyles.text11w400(color: colors.textHint),
                  ),
                  8.verticalSpace,
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 16.sp,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
