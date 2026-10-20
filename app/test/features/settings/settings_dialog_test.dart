import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/theme/ide_theme.dart';
import 'package:hush/features/lock/presentation/lock_image_cubit.dart';
import 'package:hush/features/settings/presentation/settings_dialog.dart';
import 'package:hush/features/settings/presentation/theme_cubit.dart';

import '../../support/memory_lock_image_store.dart';
import '../../support/memory_settings_repository.dart';

void main() {
  late MemorySettingsRepository settings;
  late LockImageCubit lockImage;

  Future<void> pumpDialog(WidgetTester tester, {String? initialImage}) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    settings = MemorySettingsRepository();
    lockImage = LockImageCubit(
      settings,
      MemoryLockImageStore(),
      initial: initialImage,
    );
    addTearDown(lockImage.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: IdeTheme.dark(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit(settings)),
            BlocProvider.value(value: lockImage),
          ],
          child: Scaffold(
            body: SettingsDialog(pickImage: () async => '/tmp/my_ide.png'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('내 스크린샷을 골라 확인하면 잠금 화면 이미지로 저장', (tester) async {
    await pumpDialog(tester);

    await tester.tap(find.text('기본 코드 화면'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('내 스크린샷').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('이미지 선택…'));
    await tester.pumpAndSettle();

    expect(lockImage.state, isNull);

    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(lockImage.state, '/tmp/my_ide.png');
    expect(settings.lockImagePath, '/tmp/my_ide.png');
  });

  testWidgets('기본 코드 화면으로 바꾸고 확인하면 이미지 지움', (tester) async {
    await pumpDialog(tester, initialImage: '/tmp/old.png');

    await tester.tap(find.text('내 스크린샷'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('기본 코드 화면').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(lockImage.state, isNull);
  });
}
