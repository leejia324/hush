class Message {
  const Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.isSystem = false,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool isSystem;
}
