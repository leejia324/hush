import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/chat/data/fake_chat_repository.dart';
import 'package:hush/features/chat/domain/member.dart';
import 'package:hush/features/chat/domain/room.dart';
import 'package:hush/features/chat/presentation/bloc/chat_cubit.dart';

class _FailingRepository extends FakeChatRepository {
  @override
  Future<List<Room>> fetchRooms() async => throw Exception('network');
}

class _SlowMembersRepository extends FakeChatRepository {
  _SlowMembersRepository(this.slowRoomId);

  final String slowRoomId;
  final release = Completer<void>();

  @override
  Future<List<Member>> fetchMembers(String roomId) async {
    if (roomId == slowRoomId) await release.future;
    return super.fetchMembers(roomId);
  }
}

class _SlowRoomsRepository extends FakeChatRepository {
  final release = Completer<void>();

  @override
  Future<List<Room>> fetchRooms() async {
    await release.future;
    return super.fetchRooms();
  }
}

void main() {
  test('방 목록을 못 불러오면 로딩을 끝내고 실패 상태', () async {
    final cubit = ChatCubit(_FailingRepository());
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.failed, isTrue);
  });

  test('늦게 끝난 이전 방 선택이 마지막 선택을 덮어쓰지 않음', () async {
    final repository = _SlowMembersRepository('club');
    final cubit = ChatCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();

    final slow = cubit.selectRoom('club');
    await cubit.selectRoom('dorm');
    repository.release.complete();
    await slow;

    expect(cubit.state.selectedRoomId, 'dorm');
  });

  test('불러오는 중에 닫혀도 오류 없음', () async {
    final repository = _SlowRoomsRepository();
    final cubit = ChatCubit(repository);

    final loading = cubit.load();
    await cubit.close();
    repository.release.complete();

    await expectLater(loading, completes);
  });
}
