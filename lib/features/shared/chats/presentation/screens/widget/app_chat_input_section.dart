import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:base_app/core/styles/app_colors.dart';

class AppChatInputSection extends StatefulWidget {
  const AppChatInputSection({
    super.key,
    required this.onSend,
  });

  final void Function(String text, List<File> images) onSend;

  @override
  State<AppChatInputSection> createState() => _AppChatInputSectionState();
}

class _AppChatInputSectionState extends State<AppChatInputSection> {
  final TextEditingController _controller = TextEditingController();
  final List<File> _images = [];

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final XFile? result = await picker.pickImage(source: ImageSource.gallery);

      if (result != null) {
        final tempDir = await getTemporaryDirectory();
        final String safePath = '${tempDir.path}/chat_${DateTime.now().millisecondsSinceEpoch}_${result.name}';
        final File savedFile = await File(result.path).copy(safePath);

        setState(() {
          _images.clear(); // We only allow sending one image at a time
          _images.add(savedFile);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _trySend() {
    final text = _controller.text.trim();
    if (text.isEmpty && _images.isEmpty) return;

    widget.onSend(text, List.from(_images));

    setState(() {
      _images.clear();
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final bool canSend = _controller.text.trim().isNotEmpty || _images.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_images.isNotEmpty) ...[
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (ctx, i) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        right: 8.w,
                        top: 4.h,
                        bottom: 4.h,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          _images[i],
                          width: 70.w,
                          height: 70.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4.w,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _deleteImage(i),
                        child: Container(
                          padding: EdgeInsets.all(2.r),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            8.verticalSpace,
          ],
          Row(
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: Icon(
                  Icons.image_outlined,
                  size: 28.r,
                  color: colors.primary,
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (v) => setState(() {}),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _trySend(),
                  style: TextStyle(fontSize: 14.sp, color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالة...',
                    hintStyle: TextStyle(
                      color: colors.textHint,
                      fontSize: 14.sp,
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ),
              8.horizontalSpace,
              GestureDetector(
                onTap: canSend ? _trySend : null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: canSend ? 1 : 0.5,
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      size: 18.r,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
