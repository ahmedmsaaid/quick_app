import 'package:base_app/core/pagination/screens/pagination_list_view.dart';
import 'package:base_app/core/routes/app_routes.dart';

import 'package:base_app/core/exports/exports.dart';
import 'package:base_app/core/utils/jwt_helper.dart';
import 'package:base_app/core/widgets/custom_app_bar.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import '../riverpod/get_all_chats_riverpod/get_all_chats_notifier.dart';
import '../widgets/chat_item_widget.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  int? userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await getUserId();
    if (mounted) {
      ref.read(getAllChatsProvider.notifier).loadInitial();
    }
  }

  Future<void> getUserId() async {
    final result = await JwtHelper.getUserId();
    if (mounted) {
      setState(() => userId = int.tryParse(result ?? '0'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(
        title: AppStrings.chats,
        appBarColor: colors.background,
        showTrailing: false,
      ),
      body: userId == null
          ? const Center(child: LoadingButton())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  12.verticalSpace,
                  Expanded(
                    child: PaginationListView(
                      provider: getAllChatsProvider,
                      itemBuilder: (context, item, index) {
                        return ChatItemWidget(
                          item: item,
                          isCreator: userId == item.participantId,
                          onTap: () async {
                            await Navigator.of(context).pushNamed(
                              AppRoutes.chatDetailsScreen,
                              arguments: {
                                "chatId": item.id,
                                "creator": userId == item.participantId
                                    ? item.creator
                                    : item.participant
                              },
                            );
                            ref
                                .read(getAllChatsProvider.notifier)
                                .refresh();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
