import 'package:flutter/material.dart';

import '../../../../core/theme/ide_colors.dart';
import '../../../../core/theme/ide_theme.dart';
import '../../domain/room.dart';
import 'file_tree_icon.dart';

class ProjectPanel extends StatelessWidget {
  const ProjectPanel({
    super.key,
    required this.rooms,
    required this.selectedRoomId,
    required this.onSelect,
    required this.width,
  });

  final List<Room> rooms;
  final String? selectedRoomId;
  final ValueChanged<String> onSelect;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    final code = IdeTheme.ui(colors).copyWith(fontSize: 13);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 32,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  '프로젝트 ▾',
                  style: code.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Tooltip(
                  message: '새 채팅방 ⌘N',
                  child: IconButton(
                    onPressed: () {},
                    iconSize: 16,
                    color: colors.comment,
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                const _TreeRow(
                  depth: 0,
                  icon: FileTreeIconType.module,
                  label: 'study-notes',
                  detail: '~/IdeaProjects/study-notes',
                  expanded: true,
                  bold: true,
                ),
                const _TreeRow(
                  depth: 1,
                  icon: FileTreeIconType.configFolder,
                  label: '.gradle',
                  expanded: false,
                ),
                const _TreeRow(
                  depth: 1,
                  icon: FileTreeIconType.configFolder,
                  label: '.idea',
                  expanded: false,
                ),
                const _TreeRow(
                  depth: 1,
                  icon: FileTreeIconType.excludedFolder,
                  label: 'build',
                  expanded: false,
                  excluded: true,
                ),
                const _TreeRow(
                  depth: 1,
                  icon: FileTreeIconType.sourceFolder,
                  label: 'src/main/kotlin',
                  expanded: true,
                ),
                const _TreeRow(
                  depth: 2,
                  icon: FileTreeIconType.packageFolder,
                  label: 'notes.rooms',
                  expanded: true,
                ),
                for (final room in rooms)
                  _RoomRow(
                    room: room,
                    selected: room.id == selectedRoomId,
                    onTap: () => onSelect(room.id),
                  ),
                const _TreeRow(
                  depth: 1,
                  icon: FileTreeIconType.gitignore,
                  label: '.gitignore',
                ),
                const _TreeRow(
                  depth: 1,
                  icon: FileTreeIconType.kotlinScript,
                  label: 'build.gradle.kts',
                ),
                const _TreeRow(
                  depth: 1,
                  icon: FileTreeIconType.kotlinScript,
                  label: 'settings.gradle.kts',
                ),
                const _TreeRow(
                  depth: 1,
                  icon: FileTreeIconType.markdown,
                  label: 'README.md',
                ),
                const _TreeRow(
                  depth: 0,
                  icon: FileTreeIconType.library,
                  label: '외부 라이브러리',
                  expanded: false,
                ),
                const _TreeRow(
                  depth: 0,
                  icon: FileTreeIconType.scratch,
                  label: '스크래치 및 콘솔',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.depth,
    required this.icon,
    required this.label,
    this.detail,
    this.expanded,
    this.bold = false,
    this.excluded = false,
  });

  static const indent = 18.0;

  final int depth;
  final FileTreeIconType icon;
  final String label;
  final String? detail;
  final bool? expanded;
  final bool bold;
  final bool excluded;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          SizedBox(width: 8 + depth * indent),
          SizedBox(
            width: 14,
            child: expanded == null
                ? null
                : Icon(
                    expanded! ? Icons.expand_more : Icons.chevron_right,
                    size: 14,
                    color: colors.comment,
                  ),
          ),
          const SizedBox(width: 2),
          FileTreeIcon(icon),
          const SizedBox(width: 6),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      color: excluded ? colors.keyword : colors.text,
                      fontWeight: bold ? FontWeight.w600 : null,
                    ),
                  ),
                  if (detail != null)
                    TextSpan(
                      text: '  $detail',
                      style: TextStyle(color: colors.comment),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: IdeTheme.ui(colors).copyWith(fontSize: 13, height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomRow extends StatelessWidget {
  const _RoomRow({
    required this.room,
    required this.selected,
    required this.onTap,
  });

  final Room room;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    final unread = room.unreadCount > 0;
    final style = IdeTheme.ui(colors).copyWith(
      fontSize: 13,
      height: 1,
      color: unread ? colors.accent : colors.text,
      fontWeight: unread ? FontWeight.w600 : null,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 24,
        color: selected ? colors.selection : null,
        child: Row(
          children: [
            const SizedBox(width: 8 + 3 * _TreeRow.indent + 16),
            const FileTreeIcon(FileTreeIconType.kotlin),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${room.name}.kt',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            if (unread) ...[
              const SizedBox(width: 6),
              Text('${room.unreadCount}', style: style),
            ],
          ],
        ),
      ),
    );
  }
}
