import 'package:flutter/material.dart';

import 'capture_guard/capture_test_page.dart';

void main() {
  runApp(const HushApp());
}

class HushApp extends StatelessWidget {
  const HushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'hush',
      debugShowCheckedModeBanner: false,
      home: CaptureTestPage(),
    );
  }
}
