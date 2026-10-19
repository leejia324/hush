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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await AppShell().start();
  LicenseRegistry.addLicense(_fontLicenses);

  runApp(HushApp(repository: FakeChatRepository()));
}

Stream<LicenseEntry> _fontLicenses() async* {
  final license = await rootBundle.loadString('assets/fonts/d2coding/OFL.txt');
  yield LicenseEntryWithLineBreaks(const ['D2Coding'], license);
}

class HushApp extends StatelessWidget {
  const HushApp({super.key, required this.repository});

  final ChatRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: repository,
      child: MaterialApp(
        title: 'hush',
        debugShowCheckedModeBanner: false,
        theme: IdeTheme.light(),
        darkTheme: IdeTheme.dark(),
        home: const ChatPage(),
      ),
    );
  }
}
