import 'dart:async';

import '../domain/chat_repository.dart';
import '../domain/member.dart';
import '../domain/message.dart';
import '../domain/room.dart';

class FakeChatRepository implements ChatRepository {
  FakeChatRepository({DateTime Function()? now}) : _now = now ?? DateTime.now {
    _seed();
  }

  static const meId = 'me';

  final DateTime Function() _now;
  final _rooms = <String, Room>{};
  final _members = <String, List<Member>>{};
  final _messages = <String, List<Message>>{};
  final _controllers = <String, StreamController<List<Message>>>{};
  var _nextId = 0;

  @override
  Future<List<Room>> fetchRooms() async => _rooms.values.toList();

  @override
  Future<List<Member>> fetchMembers(String roomId) async =>
      List.unmodifiable(_members[roomId] ?? const []);

  @override
  Stream<List<Message>> watchMessages(String roomId) async* {
    yield _snapshot(roomId);
    yield* _controller(roomId).stream;
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required String text,
  }) async {
    _messages
        .putIfAbsent(roomId, () => [])
        .add(
          Message(
            id: 'm${_nextId++}',
            roomId: roomId,
            senderId: meId,
            text: text,
            sentAt: _now(),
          ),
        );
    _controller(roomId).add(_snapshot(roomId));
  }

  @override
  Future<void> markAsRead(String roomId) async {
    final room = _rooms[roomId];
    if (room == null) return;
    _rooms[roomId] = room.copyWith(unreadCount: 0, lastReadAt: _now());
  }

  List<Message> _snapshot(String roomId) =>
      List.unmodifiable(_messages[roomId] ?? const []);

  StreamController<List<Message>> _controller(String roomId) =>
      _controllers.putIfAbsent(roomId, StreamController.broadcast);

  void _seed() {
    const me = Member(id: meId, nickname: '나', colorIndex: 0, isMe: true);
    const cat = Member(id: 'cat', nickname: '고양이발', colorIndex: 1);
    const dawn = Member(id: 'dawn', nickname: '새벽세시', colorIndex: 2);
    const fries = Member(id: 'fries', nickname: '감자튀김', colorIndex: 3);

    final today = _now();
    DateTime at(int hour, int minute) =>
        DateTime(today.year, today.month, today.day, hour, minute);

    _rooms['team'] = Room(
      id: 'team',
      name: '수행평가조',
      unreadCount: 1,
      lastReadAt: at(14, 17),
    );
    _members['team'] = const [me, cat, dawn, fries];
    _messages['team'] = [
      _message('team', cat.id, '발표 자료는 오늘 밤 11시까지 공유 폴더에 올릴게', at(14, 4)),
      _message('team', dawn.id, '잠깐 나 할 말 있어', at(14, 15)),
      _message('team', dawn.id, '아까 쌤이 따로 불렀는데', at(14, 15)),
      _message(
        'team',
        dawn.id,
        '발표 끝나고 나올 질문 리스트 받았어\n1. 주제 선정 이유\n2. ||자료 출처 어디서 찾았는지||\n3. 역할 분담 어떻게 했는지',
        at(14, 16),
      ),
      _message('team', dawn.id, '||이거 다른 조한테는 말하지 마|| ㅋㅋ', at(14, 16)),
      _message('team', fries.id, '감자 → 감자튀김', at(14, 17), isSystem: true),
      _message('team', fries.id, '그럼 **9시 반**에 디코에서 리허설 ㄱ?', at(14, 18)),
    ];

    _rooms['club'] = const Room(id: 'club', name: '동아리방', unreadCount: 2);
    _members['club'] = const [me, cat];
    _messages['club'] = [
      _message('club', cat.id, '부스 포스터 시안 봤어?', at(9, 30)),
      _message('club', cat.id, '||회장이 색 바꾸재||', at(9, 31)),
    ];

    _rooms['dorm'] = const Room(id: 'dorm', name: '기숙사302');
    _members['dorm'] = const [me, fries];
    _messages['dorm'] = [];
  }

  Message _message(
    String roomId,
    String senderId,
    String text,
    DateTime sentAt, {
    bool isSystem = false,
  }) {
    return Message(
      id: 'm${_nextId++}',
      roomId: roomId,
      senderId: senderId,
      text: text,
      sentAt: sentAt,
      isSystem: isSystem,
    );
  }
}
