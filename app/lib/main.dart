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
import 'features/settings/data/local_settings_repository.dart';
import 'features/settings/domain/settings_repository.dart';
import 'features/settings/domain/theme_preference.dart';
import 'features/settings/presentation/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await AppShell().start();
  LicenseRegistry.addLicense(_fontLicenses);

  final settings = LocalSettingsRepository();
  runApp(
    HushApp(
      repository: FakeChatRepository(),
      settingsRepository: settings,
      initialTheme: await settings.loadTheme(),
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
    this.initialTheme = ThemePreference.system,
  });

  final ChatRepository repository;
  final SettingsRepository settingsRepository;
  final ThemePreference initialTheme;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: repository),
        RepositoryProvider.value(value: settingsRepository),
      ],
      child: BlocProvider(
        create: (_) => ThemeCubit(settingsRepository, initial: initialTheme),
        child: BlocBuilder<ThemeCubit, ThemePreference>(
          builder: (context, theme) => MaterialApp(
            title: 'hush',
            debugShowCheckedModeBanner: false,
            theme: IdeTheme.light(),
            darkTheme: IdeTheme.dark(),
            themeMode: theme.themeMode,
            home: const ChatPage(),
          ),
        ),
      ),
    );
  }
}
