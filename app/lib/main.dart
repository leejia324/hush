import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/platform/app_shell.dart';
import 'native_check/native_check_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await AppShell().start();

  runApp(const HushApp());
}

class HushApp extends StatelessWidget {
  const HushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'hush',
      debugShowCheckedModeBanner: false,
      home: NativeCheckPage(),
    );
  }
}
