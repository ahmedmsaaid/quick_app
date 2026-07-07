import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:photo_view/photo_view.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/network/api_constants.dart';

import '../../../data/models/app_chat_message_model.dart';

class AppChatBubble extends StatelessWidget {
  const AppChatBubble({super.key, required this.messageModel, this.avatar});

  final AppChatMessageGrpcModel messageModel;
  final String? avatar;

  @override
  Widget build(BuildContext context) {
    int extractedId = 0;
    try {
      final token = CacheHelper.getString(CacheKeys.token) ?? '';
      if (token.isNotEmpty) {
        final decoded = JwtDecoder.decode(token);
        final rawVal = decoded['UserId'] ??
            decoded['userId'] ??
            decoded['id'] ??
            decoded['nameid'] ??
            decoded['sub'] ??
            decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
        if (rawVal != null) {
          extractedId = int.tryParse(rawVal.toString()) ?? 0;
        }
      }
    } catch (e) {
      print('Error parsing token in AppChatBubble: $e');
    }

    final isMe = extractedId == messageModel.creatorId;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundImage: avatar != null && avatar!.isNotEmpty
                  ? NetworkImage(avatar!) as ImageProvider
                  : const AssetImage('assets/image/logo.png'),
            ),
            8.horizontalSpace,
          ],
          Flexible(child: _buildMessageBubble(context, isMe)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, bool isMe) {
    final colors = AppColors(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    final isImage = messageModel.mediaUrl != null && messageModel.mediaUrl!.isNotEmpty;
    final hasText = messageModel.content != null && messageModel.content!.isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        decoration: _buildBubbleDecoration(context, isMe),
        child: ClipRRect(
          borderRadius: _getBorderRadius(isMe),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isImage) 4.verticalSpace,
              if (isImage) _buildImageContent(context, messageModel.mediaUrl),
              if (hasText && isImage) 4.verticalSpace,
              if (hasText)
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, isImage ? 4.h : 10.h, 12.w, 4.h),
                  child: _buildTextMessage(context, messageModel.content!, isMe),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 6.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildTimeLabel(context, isMe),
                    if (isMe) ...[
                      4.horizontalSpace,
                      _buildReadStatus(context, isMe, messageModel.isRead),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BorderRadiusDirectional _getBorderRadius(bool isMe) {
    return BorderRadiusDirectional.only(
      topStart: Radius.circular(16.r),
      topEnd: Radius.circular(16.r),
      bottomStart: Radius.circular(isMe ? 16.r : 2.r),
      bottomEnd: Radius.circular(isMe ? 2.r : 16.r),
    );
  }

  BoxDecoration _buildBubbleDecoration(BuildContext context, bool isMe) {
    final colors = AppColors(context);
    return BoxDecoration(
      color: isMe ? colors.primary : colors.surface,
      borderRadius: _getBorderRadius(isMe),
      boxShadow: [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      border: isMe
          ? null
          : Border.all(
              color: colors.divider.withValues(alpha: 0.1),
              width: 1,
            ),
    );
  }

  Widget _buildImageContent(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    final fullUrl = imageUrl.startsWith('http') ? imageUrl : '${ApiConstants.streamUrl}$imageUrl';

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, fullUrl),
      child: Hero(
        tag: imageUrl,
        child: Container(
          width: double.infinity,
          height: 160.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(fullUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoView(
            imageProvider: NetworkImage(url),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
          ),
        ),
      ),
    );
  }

  Widget _buildTextMessage(BuildContext context, String text, bool isMe) {
    final colors = AppColors(context);
    return Text(
      text,
      textAlign: TextAlign.start,
      style: AppTextStyles.text14w400(
        color: isMe ? Colors.white : colors.textPrimary,
      ),
    );
  }

  Widget _buildTimeLabel(BuildContext context, bool isMe) {
    final colors = AppColors(context);
    return Text(
      messageModel.createdOn,
      style: AppTextStyles.text10w400(
        color: isMe ? Colors.white.withValues(alpha: 0.8) : colors.textHint,
      ),
    );
  }

  Widget _buildReadStatus(BuildContext context, bool isMe, bool isRead) {
    return Icon(
      isRead ? Icons.done_all : Icons.done,
      size: 14.sp,
      color: Colors.white.withValues(alpha: 0.8),
    );
  }
}
