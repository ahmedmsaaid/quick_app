import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

import 'widget/app_chat_app_bar_section.dart';
import 'widget/app_chat_input_section.dart';
import 'widget/app_chat_message_section.dart';
import '../riverpod/chats_provider.dart';
import '../../data/enums/role_type_enum.dart';
import '../../data/models/app_message_type.dart';

class AppChatScreen extends ConsumerStatefulWidget {
  const AppChatScreen({super.key, required this.appChatArgument});

  final AppChatArgument appChatArgument;

  @override
  ConsumerState<AppChatScreen> createState() => _AppChatScreenState();
}

class _AppChatScreenState extends ConsumerState<AppChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatRoomProvider(widget.appChatArgument.recipientId).notifier)
          .initChat(chatId: widget.appChatArgument.chatId);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    await ref.read(chatRoomProvider(widget.appChatArgument.recipientId).notifier)
        .fetchMessages(chatId: widget.appChatArgument.chatId, isRefresh: false);
  }

  void _handleSend(String text, List<File> images) {
    final notifier = ref.read(chatRoomProvider(widget.appChatArgument.recipientId).notifier);
    if (images.isNotEmpty) {
      notifier.sendMediaMessage(
        AppMessageType.image,
        images,
        text,
      );
    } else if (text.isNotEmpty) {
      notifier.sendTextMessage(text);
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    // Cancel gRPC stream and REST polling timer when leaving chat
    ref.read(chatRoomProvider(widget.appChatArgument.recipientId).notifier).disconnect();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final roomState = ref.watch(chatRoomProvider(widget.appChatArgument.recipientId));

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          AppChatAppBarSection(
            image: widget.appChatArgument.recipientImage,
            name: widget.appChatArgument.recipientName,
            userId: widget.appChatArgument.recipientId,
            type: widget.appChatArgument.typeEnum,
            profileId: widget.appChatArgument.profileId,
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (roomState.isLoading && roomState.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (roomState.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد رسائل بعد',
                      style: AppTextStyles.text14w400(color: colors.textSecondary),
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      itemCount: roomState.messages.length,
                      itemBuilder: (context, index) {
                        final msg = roomState.messages[index];
                        return AppChatBubble(
                          messageModel: msg,
                          avatar: widget.appChatArgument.recipientImage,
                        );
                      },
                    ),
                    if (roomState.isLoadingMore)
                      const Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: AppChatInputSection(onSend: _handleSend),
          ),
        ],
      ),
    );
  }
}

class AppChatArgument {
  final int? chatId;
  final int recipientId;
  final RoleTypeEnum typeEnum;
  final int profileId;
  final String recipientName;
  final String recipientImage;

  AppChatArgument({
    this.chatId,
    required this.profileId,
    required this.typeEnum,
    required this.recipientId,
    required this.recipientName,
    required this.recipientImage,
  });
}
