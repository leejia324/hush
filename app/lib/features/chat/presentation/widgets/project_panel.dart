import 'package:flutter/material.dart';

import '../../../../core/theme/ide_colors.dart';
import '../../../../core/theme/ide_theme.dart';
import '../../domain/room.dart';

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
                  'Project ▾',
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
                _TreeRow(
                  depth: 0,
                  icon: Icons.folder_outlined,
                  label: 'study-notes',
                  expanded: true,
                ),
                _TreeRow(depth: 1, icon: Icons.folder_outlined, label: '.idea'),
                _TreeRow(
                  depth: 1,
                  icon: Icons.folder_outlined,
                  label: 'src/main/kotlin',
                  expanded: true,
                ),
                _TreeRow(
                  depth: 2,
                  icon: Icons.folder_outlined,
                  label: 'notes.rooms',
                  expanded: true,
                ),
                for (final room in rooms)
                  _RoomRow(
                    room: room,
                    selected: room.id == selectedRoomId,
                    onTap: () => onSelect(room.id),
                  ),
                _TreeRow(
                  depth: 1,
                  icon: Icons.description_outlined,
                  label: 'build.gradle.kts',
                ),
                _TreeRow(
                  depth: 1,
                  icon: Icons.description_outlined,
                  label: 'README.md',
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
    this.expanded,
  });

  final int depth;
  final IconData icon;
  final String label;
  final bool? expanded;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          SizedBox(width: 8 + depth * 16.0),
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
          Icon(icon, size: 15, color: colors.comment),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
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
            const SizedBox(width: 8 + 3 * 16.0 + 16),
            Container(
              width: 14,
              height: 14,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.property,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'K',
                style: TextStyle(fontSize: 9, color: Colors.white, height: 1),
              ),
            ),
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
