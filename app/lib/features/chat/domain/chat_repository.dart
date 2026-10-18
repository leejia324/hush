import 'member.dart';
import 'message.dart';
import 'room.dart';

abstract interface class ChatRepository {
  Future<List<Room>> fetchRooms();

  Future<List<Member>> fetchMembers(String roomId);

  Stream<List<Message>> watchMessages(String roomId);

  Future<void> sendMessage({required String roomId, required String text});

  Future<void> markAsRead(String roomId);
}
