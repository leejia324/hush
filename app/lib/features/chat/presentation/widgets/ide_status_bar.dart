import 'package:flutter/material.dart';

import '../../../../core/theme/ide_colors.dart';
import '../../../../core/theme/ide_theme.dart';

class IdeStatusBar extends StatelessWidget {
  const IdeStatusBar({
    super.key,
    required this.fileName,
    required this.lineCount,
  });

  final String? fileName;
  final int lineCount;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    final style = IdeTheme.code(colors)
        .copyWith(fontSize: 12, height: 1, color: colors.comment);
    final path = [
      'study-notes',
      'src',
      'main',
      'kotlin',
      'notes',
      'rooms',
      ?fileName,
    ].join(' › ');

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(path, style: style, overflow: TextOverflow.ellipsis),
          ),
          Text('$lineCount:1', style: style),
          const SizedBox(width: 16),
          Text('LF', style: style),
          const SizedBox(width: 16),
          Text('UTF-8', style: style),
          const SizedBox(width: 16),
          Text('4 spaces', style: style),
          const SizedBox(width: 16),
          Tooltip(
            message: '모든 메시지는 보낸 지 24시간 뒤 사라짐',
            child: Icon(Icons.schedule, size: 13, color: colors.comment),
          ),
        ],
      ),
    );
  }
}
