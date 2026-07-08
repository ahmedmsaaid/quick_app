// lib/features/chat/presentation/screens/chat_details_screen.dart
import 'package:base_app/core/models/creator_response.dart';

import 'package:base_app/core/exports/exports.dart';
import 'package:base_app/core/widgets/custom_app_bar.dart';
import '../riverpod/app_chat_grbc_notifier.dart';
import '../riverpod/app_chat_grbc_state.dart';
import '../widgets/chat_details_widgets/chat_bubble.dart';

class ChatDetailsScreen extends ConsumerStatefulWidget {
  const ChatDetailsScreen({super.key, this.chatId, required this.creator});

  final int? chatId;
  final CreatorResponse creator;

  @override
  ConsumerState<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends ConsumerState<ChatDetailsScreen> {
  late AppChatGrbcNotifier _chatNotifier;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _chatNotifier = ref.read(appChatGrbcProvider.notifier);
      await _chatNotifier.connect(
        chatId: widget.chatId,
        targetUserId: widget.creator.id,
      );
      await _chatNotifier.getAllMessages(
        chatId: widget.chatId,
        targetUserId: widget.creator.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    final chatState = ref.watch(appChatGrbcProvider);
    final chatNotifier = ref.read(appChatGrbcProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(
        title: widget.creator.name ?? '',
        imageUrl: widget.creator.photo ?? widget.creator.avatar,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _MessagesList(
                state: chatState,
                colors: colors,
                notifier: chatNotifier,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: MessageInput(
                onSend: (text, voicePath) {
                  if (voicePath != null && voicePath.isNotEmpty) {
                    chatNotifier.sendVoiceRecordMessage(
                      recipientId: widget.creator.id,
                      filePath: voicePath,
                    );
                  } else {
                    chatNotifier.sendTextMessage(
                      recipientId: widget.creator.id,
                      message: text,
                    );
                  }
                },
              ),
            ),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final AppChatGrbcState state;
  final AppColors colors;
  final AppChatGrbcNotifier notifier;

  const _MessagesList({
    required this.state,
    required this.colors,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return state.maybeWhen(
      loaded: (messages, currentUserId) {
        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - index - 1];
            final isMe = notifier.isMyMessage(message.creatorId);

            return ChatBubble(message: message, isMe: isMe);
          },
        );
      },
      connecting: () => const Center(child: CircularProgressIndicator()),
      sendingMessage: () => const Center(child: CircularProgressIndicator()),
      error: (msg) => Center(child: Text(msg)),
      orElse: () => const SizedBox.shrink(),
    );
  }
}


