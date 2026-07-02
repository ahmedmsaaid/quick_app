import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_app_bar.dart';

import 'widget/app_chat_list_item.dart';
import '../riverpod/chats_provider.dart';

class AppChatsListScreen extends ConsumerStatefulWidget {
  const AppChatsListScreen({super.key});

  @override
  ConsumerState<AppChatsListScreen> createState() => _AppChatsListScreenState();
}

class _AppChatsListScreenState extends ConsumerState<AppChatsListScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    controller.addListener(() {
      if (controller.position.pixels >=
          controller.position.maxScrollExtent * 0.8) {
        loadMore();
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    // Fetch list of chats
    Future.microtask(() {
      ref.read(chatsListProvider.notifier).fetchChats(isRefresh: true);
    });
  }

  void loadMore() {
    ref.read(chatsListProvider.notifier).fetchChats(isRefresh: false);
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final state = ref.watch(chatsListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(
        title: 'الدردشات',
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.chats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.chats.isEmpty) {
            return Center(
              child: Text(
                'حدث خطأ في تحميل الدردشات',
                style: AppTextStyles.text14w400(color: colors.textSecondary),
              ),
            );
          }

          if (state.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64.sp, color: colors.textHint),
                  16.verticalSpace,
                  Text(
                    'لا توجد دردشات نشطة',
                    style: AppTextStyles.text14w600(color: colors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(chatsListProvider.notifier).fetchChats(isRefresh: true);
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ListView.separated(
                  controller: controller,
                  itemCount: state.chats.length + (state.isLoadingMore ? 1 : 0),
                  padding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 16.w,
                  ),
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    if (index == state.chats.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final chat = state.chats[index];
                    final animation = CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        (index / state.chats.length).clamp(0.0, 1.0),
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    );

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.2, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: AppChatListItem(chat: chat, index: index),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
