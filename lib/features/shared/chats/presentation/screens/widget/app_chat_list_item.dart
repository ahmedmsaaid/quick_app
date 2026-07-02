import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/cached_network_image.dart';

import '../../../data/models/app_chat_default_models/app_get_all_chats_result_model.dart';
import '../../../data/enums/role_type_enum.dart';
import '../../riverpod/chats_provider.dart';
import '../app_chat_screen.dart';

class AppChatListItem extends ConsumerStatefulWidget {
  final AppGetAllChatsResultModel chat;
  final int index;

  const AppChatListItem({super.key, required this.chat, required this.index});

  @override
  ConsumerState<AppChatListItem> createState() => _AppChatListItemState();
}

class _AppChatListItemState extends ConsumerState<AppChatListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutQuad),
    );

    _shadowAnimation = Tween<double>(begin: 4, end: 14).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    final recipientId = widget.chat.user?.id ?? 0;
    if (recipientId == 0) return;

    await Navigator.of(context).pushNamed(
      AppRoutes.chatDetailsScreen,
      arguments: AppChatArgument(
        recipientId: recipientId,
        recipientName: widget.chat.user?.name ?? '',
        recipientImage: widget.chat.user?.photoUrl ?? '',
        chatId: widget.chat.chatId,
        profileId: widget.chat.profileId ?? 0,
        typeEnum: widget.chat.user?.type ?? RoleTypeEnum.customer,
      ),
    );

    // Refresh chats when coming back
    ref.read(chatsListProvider.notifier).fetchChats(isRefresh: true, closedChatId: widget.chat.chatId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final displayName = widget.chat.user?.name ?? 'Chat';
    final lastMessage = widget.chat.message?.content ?? '';
    final time = widget.chat.message?.createdOn ?? '';

    return GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapCancel: () => _hoverController.reverse(),
      onTapUp: (_) => _hoverController.reverse(),
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.08),
                    blurRadius: _shadowAnimation.value,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: colors.divider.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'chat_avatar_${widget.chat.chatId}',
                    child: CircleAvatar(
                      radius: 26.r,
                      backgroundColor: colors.divider,
                      backgroundImage: widget.chat.user?.photoUrl != null && widget.chat.user!.photoUrl!.isNotEmpty
                          ? NetworkImage(widget.chat.user!.photoUrl!) as ImageProvider
                          : const AssetImage('assets/image/logo.png'),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.text14w600(color: colors.textPrimary),
                              ),
                            ),
                            Text(
                              time,
                              style: AppTextStyles.text10w400(color: colors.textHint),
                            ),
                          ],
                        ),
                        6.verticalSpace,
                        Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text12w400(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  8.horizontalSpace,
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
