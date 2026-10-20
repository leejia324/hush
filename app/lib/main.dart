import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'core/platform/app_shell.dart';
import 'core/theme/ide_theme.dart';
import 'features/chat/data/fake_chat_repository.dart';
import 'features/chat/domain/chat_repository.dart';
import 'features/chat/presentation/chat_page.dart';
import 'features/lock/data/local_authenticator.dart';
import 'features/lock/data/local_lock_image_store.dart';
import 'features/lock/domain/lock_image_store.dart';
import 'features/lock/presentation/idle_lock.dart';
import 'features/lock/presentation/lock_cubit.dart';
import 'features/lock/presentation/lock_gate.dart';
import 'features/lock/presentation/lock_image_cubit.dart';
import 'features/settings/data/local_settings_repository.dart';
import 'features/settings/domain/settings_repository.dart';
import 'features/settings/domain/theme_preference.dart';
import 'features/settings/presentation/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final shell = AppShell();
  await shell.start();
  LicenseRegistry.addLicense(_fontLicenses);

  final settings = LocalSettingsRepository();
  final lock = LockCubit(LocalAuthenticator());
  shell.bindLock(
    locked: lock.isLocked,
    lockedChanges: lock.stream.map((_) => lock.isLocked).distinct(),
    onLock: lock.lock,
    onUnlock: lock.unlock,
  );
  runApp(
    HushApp(
      repository: FakeChatRepository(),
      settingsRepository: settings,
      lockCubit: lock,
      initialTheme: await settings.loadTheme(),
      initialLockImagePath: await settings.loadLockImagePath(),
    ),
  );
}

Stream<LicenseEntry> _fontLicenses() async* {
  final license = await rootBundle.loadString('assets/fonts/d2coding/OFL.txt');
  yield LicenseEntryWithLineBreaks(const ['D2Coding'], license);
}

class HushApp extends StatelessWidget {
  const HushApp({
    super.key,
    required this.repository,
    required this.settingsRepository,
    required this.lockCubit,
    this.initialTheme = ThemePreference.system,
    this.unlockOnStart = true,
    this.initialLockImagePath,
    this.lockImageStore,
  });

  final ChatRepository repository;
  final SettingsRepository settingsRepository;
  final ThemePreference initialTheme;
  final LockCubit lockCubit;
  final bool unlockOnStart;
  final String? initialLockImagePath;
  final LockImageStore? lockImageStore;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: repository),
        RepositoryProvider.value(value: settingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                ThemeCubit(settingsRepository, initial: initialTheme),
          ),
          BlocProvider.value(value: lockCubit),
          BlocProvider(
            create: (_) => LockImageCubit(
              settingsRepository,
              lockImageStore ?? LocalLockImageStore(),
              initial: initialLockImagePath,
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemePreference>(
          builder: (context, theme) => MaterialApp(
            title: 'hush',
            debugShowCheckedModeBanner: false,
            theme: IdeTheme.light(),
            darkTheme: IdeTheme.dark(),
            themeMode: theme.themeMode,
            builder: (context, child) => IdleLock(
              child: LockGate(unlockOnStart: unlockOnStart, child: child!),
            ),
            home: const ChatPage(),
          ),
        ),
      ),
    );
  }
}
