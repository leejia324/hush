import '../../domain/member.dart';
import '../../domain/message.dart';
import '../../domain/room.dart';

class ChatState {
  const ChatState({
    this.loading = true,
    this.failed = false,
    this.rooms = const [],
    this.selectedRoomId,
    this.members = const [],
    this.messages = const [],
    this.newMessagesAfter,
  });

  final bool loading;
  final bool failed;
  final List<Room> rooms;
  final String? selectedRoomId;
  final List<Member> members;
  final List<Message> messages;
  final DateTime? newMessagesAfter;

  Room? get selectedRoom {
    for (final room in rooms) {
      if (room.id == selectedRoomId) return room;
    }
    return null;
  }

  ChatState copyWith({
    bool? loading,
    bool? failed,
    List<Room>? rooms,
    String? selectedRoomId,
    List<Member>? members,
    List<Message>? messages,
    DateTime? Function()? newMessagesAfter,
  }) {
    return ChatState(
      loading: loading ?? this.loading,
      failed: failed ?? this.failed,
      rooms: rooms ?? this.rooms,
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      members: members ?? this.members,
      messages: messages ?? this.messages,
      newMessagesAfter: newMessagesAfter != null
          ? newMessagesAfter()
          : this.newMessagesAfter,
    );
  }
}
