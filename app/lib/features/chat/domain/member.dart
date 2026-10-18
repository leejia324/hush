class Member {
  const Member({
    required this.id,
    required this.nickname,
    required this.colorIndex,
    this.isMe = false,
  });

  final String id;
  final String nickname;
  final int colorIndex;
  final bool isMe;
}
