import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:base_app/core/exports/exports.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/features/shared/chat/data/models/app_chat_message_model.dart';
import 'package:base_app/features/shared/chat/data/models/app_message_type.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../core/utils/format_date.dart';
import '../../../../../../core/widgets/cached_network_image.dart';
import 'package:base_app/core/network/api_constants.dart';

class VoiceBubbleWidget extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const VoiceBubbleWidget({super.key, required this.audioUrl, required this.isMe});

  @override
  State<VoiceBubbleWidget> createState() => _VoiceBubbleWidgetState();
}

class _VoiceBubbleWidgetState extends State<VoiceBubbleWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      final isLocal = widget.audioUrl.startsWith('/') ||
          widget.audioUrl.startsWith('content:') ||
          widget.audioUrl.startsWith('file:');

      final resolvedUrl = isLocal
          ? widget.audioUrl
          : (widget.audioUrl.startsWith('http')
              ? widget.audioUrl
              : '${ApiConstants.streamUrl}${widget.audioUrl}');

      final source = isLocal
          ? DeviceFileSource(resolvedUrl)
          : UrlSource(resolvedUrl);

      await _audioPlayer.play(source);
      if (mounted) setState(() => _isPlaying = true);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            size: 32.r,
            color: widget.isMe ? Colors.white : colors.primary,
          ),
          onPressed: _togglePlay,
        ),
        8.horizontalSpace,
        SizedBox(
          width: 140.w,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              trackHeight: 2.0,
            ),
            child: Slider(
              activeColor: widget.isMe ? Colors.white : colors.primary,
              inactiveColor: widget.isMe ? Colors.white38 : (isDark ? Colors.white12 : Colors.black12),
              value: _position.inMilliseconds.toDouble(),
              max: _duration.inMilliseconds.toDouble() > 0 
                  ? _duration.inMilliseconds.toDouble() 
                  : 100.0,
              onChanged: (value) async {
                await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
        ),
        8.horizontalSpace,
        Text(
          _formatDuration(_position),
          style: AppTextStyles.text10w500(
            color: widget.isMe ? Colors.white70 : colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final AppChatMessageGrpcModel message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    final bubble = Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(8.h),
      constraints: BoxConstraints(
        maxWidth: (MediaQuery.of(context).size.width * 0.75).clamp(0.0, 500.0),
      ),
      decoration: BoxDecoration(
        color: isMe ? colors.primaryVariant : colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
          bottomLeft: isMe ? Radius.circular(16.r) : Radius.zero,
          bottomRight: isMe ? Radius.zero : Radius.circular(16.r),
        ),
      ),
      child: message.type == AppMessageType.image
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CustomNetworkImage.rectangle(
                    imageUrl: message.mediaUrl,
                    width: double.infinity,
                    height: 160.h,
                    radius: 12.r,
                    fit: BoxFit.cover,
                    color: isMe ? Colors.white : colors.textPrimary,
                  ),
                ),
                4.verticalSpace,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.createdOn,
                      style: AppTextStyles.text14w500(
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : colors.textSecondary,
                      ),
                    ),
                    if (isMe) ...[
                      4.horizontalSpace,
                      Icon(
                        FontAwesomeIcons.checkDouble,
                        size: 11.r,
                        color: message.isRead 
                            ? const Color(0xFF0077FF)
                            : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            )
          : message.type == AppMessageType.audio
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    VoiceBubbleWidget(
                      audioUrl: message.mediaUrl ?? '',
                      isMe: isMe,
                    ),
                    4.verticalSpace,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.createdOn,
                          style: AppTextStyles.text10w500(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.7)
                                : colors.textSecondary,
                          ),
                        ),
                        if (isMe) ...[
                          4.horizontalSpace,
                          Icon(
                            FontAwesomeIcons.checkDouble,
                            size: 10.r,
                            color: message.isRead 
                                ? const Color(0xFF0077FF)
                                : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        message.content ?? '',
                        style: AppTextStyles.text16w400(
                          color: isMe ? Colors.white : colors.textPrimary,
                        ),
                      ),
                    ),
                    10.horizontalSpace,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.createdOn,
                          style: AppTextStyles.text10w500(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.7)
                                : colors.textSecondary,
                          ),
                        ),
                        if (isMe) ...[
                          4.horizontalSpace,
                          Icon(
                            FontAwesomeIcons.checkDouble,
                            size: 10.r,
                            color: message.isRead 
                                ? const Color(0xFF0077FF)
                                : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Tooltip(
        message: isMe
            ? (message.isRead && message.readOn != null
                ? 'تمت القراءة في ${formatDateChatPMAM(message.readOn!.toLocal())}'
                : 'تم التسليم')
            : 'وصلت في ${message.createdOn}',
        triggerMode: TooltipTriggerMode.longPress,
        child: bubble,
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final void Function(String text, String? voicePath) onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _recordTimer;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _recordTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        _recordTimer?.cancel();
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _recordDuration++);
        });
      }
    } catch (e) {
      print('❌ Error starting recording: $e');
    }
  }

  Future<void> _stopRecording(bool send) async {
    try {
      _recordTimer?.cancel();
      _recordTimer = null;
      
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);

      if (send && path != null) {
        widget.onSend('', path);
      }
    } catch (e) {
      print('❌ Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      _recordTimer?.cancel();
      _recordTimer = null;
      await _audioRecorder.stop();
      setState(() => _isRecording = false);
    } catch (e) {
      print('❌ Error cancelling recording: $e');
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text, null);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    if (_isRecording) {
      final minutes = (_recordDuration ~/ 60).toString();
      final seconds = (_recordDuration % 60).toString().padLeft(2, '0');
      
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colors.backGroundType,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.mic, color: colors.error, size: 24.r),
            8.horizontalSpace,
            Text(
              'تسجيل... $minutes:$seconds',
              style: AppTextStyles.text14w500(color: colors.textPrimary),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.delete, color: colors.error, size: 24.r),
              onPressed: _cancelRecording,
            ),
            IconButton(
              icon: Icon(Icons.check_circle, color: colors.success, size: 28.r),
              onPressed: () => _stopRecording(true),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: _controller,
            hintText: AppStrings.messaging,
            fillColor: colors.backGroundType,
            minLines: 1,
            maxLines: 2,
            prefixIcon: SizedBox(
              width: 50.w,
              height: 56.h,
              child: Row(
                children: [
                  12.horizontalSpace,
                  GestureDetector(
                    onTap: _startRecording,
                    child: Icon(
                      FontAwesomeIcons.microphone,
                      color: colors.primary,
                      size: 20.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send, color: colors.primary),
          onPressed: _handleSend,
        ),
      ],
    );
  }
}


