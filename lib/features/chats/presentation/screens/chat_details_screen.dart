import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({super.key, required this.name});

  final String name;

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': AppStrings.howCanIHelpMsg, 'isMe': false},
    {'text': AppStrings.askAboutOrderMsg, 'isMe': true},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text.trim(),
          'isMe': true,
        });
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 1,
        leading: const CustomArrowBack(),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundImage: const AssetImage('assets/image/logo.png'),
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: AppTextStyles.text14w700(color: colors.textPrimary),
                  ),
                  Text(
                    '${AppStrings.onlineNowStatus}',
                    style: AppTextStyles.text10w400(color: colors.success),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone, color: colors.primary, size: 22.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: _messages.length,
              separatorBuilder: (context, index) => 15.verticalSpace,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isMe = msg['isMe'];
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isMe ? colors.primary : colors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.r),
                        topRight: Radius.circular(15.r),
                        bottomLeft: isMe ? Radius.circular(15.r) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : Radius.circular(15.r),
                      ),
                      boxShadow: [if (!isMe) BoxShadow(color: colors.shadow, blurRadius: 5)],
                    ),
                    child: Text(
                      msg['text'],
                      style: AppTextStyles.text14w400(color: isMe ? Colors.white : colors.textPrimary),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      color: colors.surface,
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _messageController,
              hintText: AppStrings.writeMessageHint,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          15.horizontalSpace,
          InkWell(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
