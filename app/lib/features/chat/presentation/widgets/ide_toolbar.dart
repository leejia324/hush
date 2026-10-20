import 'package:flutter/material.dart';

import '../../../../core/theme/ide_colors.dart';
import '../../../../core/theme/ide_theme.dart';
import 'file_tree_icon.dart';

class IdeToolbar extends StatelessWidget {
  const IdeToolbar({
    super.key,
    required this.onCover,
    required this.onLock,
    required this.onSettings,
  });

  final VoidCallback onCover;
  final VoidCallback onLock;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    final label = IdeTheme.ui(colors).copyWith(fontSize: 13, height: 1);

    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 84, right: 8),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final showDevice = width >= 830;
          final showRunLabel = width >= 660;
          final showExtras = width >= 660;
          final showRoomActions = width >= 450;

          return Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'S',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'study-notes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: label.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.expand_more, size: 16, color: colors.comment),
                    const SizedBox(width: 16),
                    Icon(Icons.call_split, size: 15, color: colors.comment),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'main',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: label,
                      ),
                    ),
                    Icon(Icons.expand_more, size: 16, color: colors.comment),
                  ],
                ),
              ),
              if (showDevice) ...[
                Icon(Icons.laptop_mac, size: 15, color: colors.comment),
                const SizedBox(width: 6),
                Text('macOS (desktop)', style: label),
                Icon(Icons.expand_more, size: 16, color: colors.comment),
                const SizedBox(width: 12),
              ],
              const FileTreeIcon(FileTreeIconType.kotlin),
              if (showRunLabel) ...[
                const SizedBox(width: 6),
                Text('NotesApp.kt', style: label),
                Icon(Icons.expand_more, size: 16, color: colors.comment),
              ],
              const SizedBox(width: 10),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: colors.string.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              if (showExtras) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.bug_report_outlined,
                  size: 17,
                  color: colors.comment,
                ),
                const SizedBox(width: 4),
                Icon(Icons.more_vert, size: 17, color: colors.comment),
              ],
              const SizedBox(width: 12),
              if (showRoomActions) ...[
                _ToolbarButton(
                  icon: Icons.link,
                  tooltip: '초대 링크',
                  onPressed: () {},
                ),
                _ToolbarButton(
                  icon: Icons.delete_outline,
                  tooltip: '방 삭제',
                  onPressed: () {},
                ),
              ],
              _ToolbarButton(
                icon: Icons.visibility_off_outlined,
                tooltip: '화면 가리기 ⌥Space',
                onPressed: onCover,
              ),
              _ToolbarButton(
                icon: Icons.lock_outline,
                tooltip: '지금 잠그기 ⇧⌘L',
                onPressed: onLock,
              ),
              if (showExtras)
                _ToolbarButton(
                  icon: Icons.search,
                  tooltip: '검색',
                  onPressed: () {},
                ),
              _ToolbarButton(
                icon: Icons.settings_outlined,
                tooltip: '설정',
                onPressed: onSettings,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: 16,
      color: IdeColors.of(context).comment,
      icon: Icon(icon),
    );
  }
}
