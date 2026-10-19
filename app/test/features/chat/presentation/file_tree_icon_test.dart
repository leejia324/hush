import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/theme/ide_theme.dart';
import 'package:hush/features/chat/presentation/widgets/file_tree_icon.dart';

void main() {
  testWidgets('모든 아이콘이 같은 크기로 그려짐', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: IdeTheme.dark(),
        home: Row(
          children: [
            for (final type in FileTreeIconType.values) FileTreeIcon(type),
          ],
        ),
      ),
    );

    for (final type in FileTreeIconType.values) {
      final size = tester.getSize(
        find.byWidgetPredicate((w) => w is FileTreeIcon && w.type == type),
      );
      expect(size, const Size.square(FileTreeIcon.size));
    }
    expect(tester.takeException(), isNull);
  });
}
