class ChatMessage {
  final String id;
  final String text;
  final DateTime time;
  final bool isMe;
  final String? avatar;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    this.avatar,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    DateTime? time,
    bool? isMe,
    String? avatar,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      avatar: avatar ?? this.avatar,
    );
  }
}
