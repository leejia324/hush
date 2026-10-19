import 'package:flutter/material.dart';

import '../../../../core/theme/ide_colors.dart';
import '../../../../core/theme/ide_theme.dart';
import 'file_tree_icon.dart';

class EditorTab {
  const EditorTab({required this.id, required this.fileName});

  final String id;
  final String fileName;
}

class EditorTabBar extends StatelessWidget {
  const EditorTabBar({
    super.key,
    required this.tabs,
    required this.activeId,
    required this.onSelect,
    required this.onClose,
  });

  final List<EditorTab> tabs;
  final String? activeId;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onClose;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colors.editorBackground,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final tab in tabs)
                  _Tab(
                    tab: tab,
                    active: tab.id == activeId,
                    closable: tabs.length > 1,
                    onTap: () => onSelect(tab.id),
                    onClose: () => onClose(tab.id),
                  ),
              ],
            ),
          ),
          Icon(Icons.more_vert, size: 16, color: colors.comment),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.tab,
    required this.active,
    required this.closable,
    required this.onTap,
    required this.onClose,
  });

  final EditorTab tab;
  final bool active;
  final bool closable;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? colors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            const FileTreeIcon(FileTreeIconType.kotlin),
            const SizedBox(width: 6),
            Text(
              tab.fileName,
              style: IdeTheme.ui(colors).copyWith(
                fontSize: 13,
                height: 1,
                color: active ? colors.text : colors.comment,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 14,
              child: closable
                  ? InkWell(
                      onTap: onClose,
                      child: Icon(Icons.close, size: 12, color: colors.comment),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
