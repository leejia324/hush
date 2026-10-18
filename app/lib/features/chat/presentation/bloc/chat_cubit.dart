import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository) : super(const ChatState());

  final ChatRepository _repository;
  StreamSubscription<void>? _messagesSubscription;

  Future<void> load() async {
    final rooms = await _repository.fetchRooms();
    emit(state.copyWith(loading: false, rooms: rooms));
    if (rooms.isNotEmpty) {
      await selectRoom(rooms.first.id);
    }
  }

  Future<void> selectRoom(String roomId) async {
    final room = state.rooms.firstWhere((room) => room.id == roomId);
    final members = await _repository.fetchMembers(roomId);
    await _messagesSubscription?.cancel();

    emit(
      state.copyWith(
        selectedRoomId: roomId,
        members: members,
        messages: const [],
        newMessagesAfter: () => room.unreadCount > 0 ? room.lastReadAt : null,
      ),
    );

    _messagesSubscription = _repository.watchMessages(roomId).listen((
      messages,
    ) {
      if (state.selectedRoomId == roomId) {
        emit(state.copyWith(messages: messages));
      }
    });

    await _repository.markAsRead(roomId);
    emit(state.copyWith(rooms: await _repository.fetchRooms()));
  }

  Future<void> send(String text) async {
    final roomId = state.selectedRoomId;
    if (roomId == null || text.trim().isEmpty) return;
    await _repository.sendMessage(roomId: roomId, text: text.trim());
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}
