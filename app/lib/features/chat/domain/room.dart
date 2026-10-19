class Room {
  const Room({
    required this.id,
    required this.name,
    this.unreadCount = 0,
    this.lastReadAt,
  });

  final String id;
  final String name;
  final int unreadCount;
  final DateTime? lastReadAt;

  Room copyWith({int? unreadCount, DateTime? lastReadAt}) {
    return Room(
      id: id,
      name: name,
      unreadCount: unreadCount ?? this.unreadCount,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
}
