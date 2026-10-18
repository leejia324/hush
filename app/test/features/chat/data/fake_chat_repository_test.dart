import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/chat/data/fake_chat_repository.dart';

void main() {
  final now = DateTime(2026, 10, 14, 15);

  test('보낸 메시지가 대화 스트림에 바로 나옴', () async {
    final repository = FakeChatRepository(now: () => now);
    final updates = repository.watchMessages('team');

    final expectation = expectLater(
      updates.map((messages) => messages.last.text),
      emitsInOrder([isNot('안녕'), '안녕']),
    );
    await Future<void>.delayed(Duration.zero);
    await repository.sendMessage(roomId: 'team', text: '안녕');

    await expectation;
  });

  test('구독 직후 바로 보낸 메시지도 빠지지 않음', () async {
    final repository = FakeChatRepository(now: () => now);
    final received = <String>[];

    final subscription = repository
        .watchMessages('dorm')
        .listen(
          (messages) => received.add(messages.map((m) => m.text).join(',')),
        );
    await repository.sendMessage(roomId: 'dorm', text: '첫 메시지');
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(received.last, '첫 메시지');
  });

  test('읽음 처리하면 안 읽은 수가 0', () async {
    final repository = FakeChatRepository(now: () => now);

    await repository.markAsRead('club');
    final rooms = await repository.fetchRooms();

    expect(rooms.firstWhere((room) => room.id == 'club').unreadCount, 0);
  });
}
