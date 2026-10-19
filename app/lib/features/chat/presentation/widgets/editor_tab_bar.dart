import 'package:flutter/material.dart';

import '../../../../core/theme/ide_colors.dart';
import '../../../../core/theme/ide_theme.dart';

class EditorTabBar extends StatelessWidget {
  const EditorTabBar({super.key, required this.fileName});

  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return Container(
      height: 32,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: fileName == null
          ? null
          : Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.editorBackground,
                border: Border(
                  bottom: BorderSide(color: colors.accent, width: 2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName!,
                    style: IdeTheme.ui(colors)
                        .copyWith(fontSize: 13, height: 1),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.close, size: 12, color: colors.comment),
                ],
              ),
            ),
    );
  }
}
