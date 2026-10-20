import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/lock/data/local_lock_image_store.dart';
import 'package:hush/features/lock/presentation/lock_image_cubit.dart';

import '../../support/memory_settings_repository.dart';

void main() {
  late Directory directory;
  late LocalLockImageStore store;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('lock_image_test');
    store = LocalLockImageStore(directory: () async => directory);
  });

  tearDown(() => directory.delete(recursive: true));

  Future<File> picked(String name) async {
    final file = File('${directory.path}/../$name');
    await file.writeAsBytes([1, 2, 3]);
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });
    return file;
  }

  test('고른 이미지를 앱 폴더로 복사해서 원본을 지워도 남음', () async {
    final source = await picked('shot_a.png');

    final saved = await store.save(source.path);
    await source.delete();

    expect(File(saved).existsSync(), isTrue);
    expect(saved, endsWith('.png'));
  });

  test('새 이미지를 고르면 이전 이미지는 지워짐', () async {
    final first = await store.save((await picked('shot_b.png')).path);
    final second = await store.save((await picked('shot_c.jpg')).path);

    expect(File(first).existsSync(), isFalse);
    expect(File(second).existsSync(), isTrue);
  });

  test('이미지를 고르면 복사본 경로를 설정에 저장', () async {
    final settings = MemorySettingsRepository();
    final cubit = LockImageCubit(settings, store);
    addTearDown(cubit.close);

    await cubit.use((await picked('shot_d.png')).path);

    expect(cubit.state, isNotNull);
    expect(settings.lockImagePath, cubit.state);
    expect(File(cubit.state!).existsSync(), isTrue);
  });
}
