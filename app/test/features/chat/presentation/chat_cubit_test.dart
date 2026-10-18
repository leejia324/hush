import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/chat/data/fake_chat_repository.dart';
import 'package:hush/features/chat/presentation/bloc/chat_cubit.dart';

void main() {
  final now = DateTime(2026, 10, 14, 15);

  late ChatCubit cubit;

  setUp(() {
    cubit = ChatCubit(FakeChatRepository(now: () => now));
  });

  tearDown(() => cubit.close());

  test('불러오면 첫 방을 열고 메시지를 받음', () async {
    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.selectedRoom?.name, '수행평가조');
    expect(cubit.state.messages, isNotEmpty);
    expect(cubit.state.members, hasLength(4));
  });

  test('안 읽은 방을 열면 새 메시지 기준 시각을 기억하고 읽음 처리', () async {
    await cubit.load();

    expect(cubit.state.newMessagesAfter, DateTime(2026, 10, 14, 14, 17));
    expect(cubit.state.selectedRoom?.unreadCount, 0);
  });

  test('보낸 메시지가 대화 끝에 붙음', () async {
    await cubit.load();
    await cubit.send('  ㅇㅋ 9시 반 ㄱㄱ  ');
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.messages.last.text, 'ㅇㅋ 9시 반 ㄱㄱ');
  });

  test('빈 메시지는 보내지 않음', () async {
    await cubit.load();
    await Future<void>.delayed(Duration.zero);
    final count = cubit.state.messages.length;

    await cubit.send('   ');
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.messages, hasLength(count));
  });

  test('다른 방을 고르면 그 방 대화로 바뀜', () async {
    await cubit.load();
    await cubit.selectRoom('club');
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.selectedRoom?.name, '동아리방');
    expect(cubit.state.messages.first.text, '부스 포스터 시안 봤어?');
  });
}
