import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/platform/screen_cover.dart';
import '../../../core/theme/ide_colors.dart';
import '../../../core/theme/ide_theme.dart';
import '../../lock/presentation/lock_cubit.dart';
import '../../settings/presentation/settings_dialog.dart';
import '../domain/chat_repository.dart';
import 'bloc/chat_cubit.dart';
import 'bloc/chat_state.dart';
import 'conversation/conversation_code.dart';
import 'widgets/conversation_view.dart';
import 'widgets/editor_tab_bar.dart';
import 'widgets/ide_status_bar.dart';
import 'widgets/ide_toolbar.dart';
import 'widgets/panel_resize_handle.dart';
import 'widgets/project_panel.dart';
import 'widgets/terminal_composer.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(context.read<ChatRepository>())..load(),
      child: ValueListenableBuilder(
        valueListenable: screenCovered,
        builder: (context, covered, child) => Stack(
          fit: StackFit.expand,
          children: [
            ExcludeFocus(
              excluding: covered,
              child: Visibility(
                visible: !covered,
                maintainState: true,
                child: child!,
              ),
            ),
            if (covered) const ScreenCover(),
          ],
        ),
        child: const _IdeLayout(),
      ),
    );
  }
}

class _IdeLayout extends StatefulWidget {
  const _IdeLayout();

  @override
  State<_IdeLayout> createState() => _IdeLayoutState();
}

class _IdeLayoutState extends State<_IdeLayout> {
  static const _minPanelWidth = 180.0;
  static const _maxPanelWidth = 480.0;
  static const _closePanelWidth = 120.0;

  bool _projectPanelOpen = true;
  final _openTabs = <String>[];
  double _terminalHeight = 240;
  double _projectPanelWidth = 260;
  double _dragWidth = 260;

  void _toggleProjectPanel() =>
      setState(() => _projectPanelOpen = !_projectPanelOpen);

  void _resizeProjectPanel(double delta) {
    setState(() {
      _dragWidth += delta;
      _projectPanelWidth = _dragWidth.clamp(_minPanelWidth, _maxPanelWidth);
    });
  }

  void _resizeTerminal(double delta) {
    setState(() {
      _terminalHeight = (_terminalHeight - delta).clamp(120.0, 600.0);
    });
  }

  void _openTab(String? roomId) {
    if (roomId == null || _openTabs.contains(roomId)) return;
    setState(() => _openTabs.add(roomId));
  }

  void _closeTab(String roomId, ChatState state) {
    if (_openTabs.length <= 1) return;
    setState(() => _openTabs.remove(roomId));
    if (state.selectedRoomId == roomId) {
      context.read<ChatCubit>().selectRoom(_openTabs.last);
    }
  }

  void _finishResize() {
    setState(() {
      if (_dragWidth < _closePanelWidth) {
        _projectPanelOpen = false;
        _projectPanelWidth = _minPanelWidth;
      }
      _dragWidth = _projectPanelWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, meta: true):
            _toggleProjectPanel,
        const SingleActivator(
          LogicalKeyboardKey.keyL,
          meta: true,
          shift: true,
        ): () =>
            context.read<LockCubit>().lock(),
      },
      child: Scaffold(
        body: BlocConsumer<ChatCubit, ChatState>(
          listenWhen: (previous, current) =>
              previous.selectedRoomId != current.selectedRoomId,
          listener: (context, state) => _openTab(state.selectedRoomId),
          builder: (context, state) {
            final room = state.selectedRoom;
            final fileName = room == null ? null : '${room.name}.kt';
            final lines = room == null
                ? null
                : ConversationCode.build(
                    roomName: room.name,
                    members: state.members,
                    messages: state.messages,
                    newMessagesAfter: state.newMessagesAfter,
                  );

            return Column(
              children: [
                IdeToolbar(
                  onCover: () => screenCovered.value = true,
                  onLock: context.read<LockCubit>().lock,
                  onSettings: () => SettingsDialog.show(context),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ToolStrip(
                        projectPanelOpen: _projectPanelOpen,
                        onToggleProjectPanel: _toggleProjectPanel,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_projectPanelOpen) ...[
                                    ProjectPanel(
                                      rooms: state.rooms,
                                      selectedRoomId: state.selectedRoomId,
                                      onSelect: context
                                          .read<ChatCubit>()
                                          .selectRoom,
                                      width: _projectPanelWidth,
                                    ),
                                    PanelResizeHandle(
                                      onDrag: _resizeProjectPanel,
                                      onDragEnd: _finishResize,
                                    ),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        EditorTabBar(
                                          tabs: [
                                            for (final room in state.rooms)
                                              if (_openTabs.contains(room.id))
                                                EditorTab(
                                                  id: room.id,
                                                  fileName: '${room.name}.kt',
                                                ),
                                          ],
                                          activeId: state.selectedRoomId,
                                          onSelect: context
                                              .read<ChatCubit>()
                                              .selectRoom,
                                          onClose: (id) => _closeTab(id, state),
                                        ),
                                        Expanded(
                                          child: ColoredBox(
                                            color: colors.editorBackground,
                                            child: state.failed
                                                ? _LoadFailed(
                                                    onRetry: context
                                                        .read<ChatCubit>()
                                                        .load,
                                                  )
                                                : lines == null
                                                ? const SizedBox.shrink()
                                                : Stack(
                                                    children: [
                                                      ConversationView(
                                                        lines: lines,
                                                      ),
                                                      Positioned(
                                                        top: 8,
                                                        right: 20,
                                                        child: Tooltip(
                                                          message: '문제 없음',
                                                          child: Icon(
                                                            Icons.check,
                                                            size: 15,
                                                            color:
                                                                colors.string,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PanelResizeHandle(
                              axis: Axis.vertical,
                              onDrag: _resizeTerminal,
                              onDragEnd: () {},
                            ),
                            TerminalComposer(
                              onSend: context.read<ChatCubit>().send,
                              height: _terminalHeight,
                            ),
                          ],
                        ),
                      ),
                      const _RightToolStrip(),
                    ],
                  ),
                ),
                IdeStatusBar(fileName: fileName, lineCount: lines?.length ?? 0),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ToolStrip extends StatelessWidget {
  const _ToolStrip({
    required this.projectPanelOpen,
    required this.onToggleProjectPanel,
  });

  final bool projectPanelOpen;
  final VoidCallback onToggleProjectPanel;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return Container(
      width: 44,
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          _StripButton(
            icon: Icons.folder_outlined,
            tooltip: '프로젝트 ⌘1',
            active: projectPanelOpen,
            onTap: onToggleProjectPanel,
          ),
          const _StripButton(icon: Icons.commit, tooltip: '커밋'),
          const _StripButton(icon: Icons.account_tree_outlined, tooltip: 'Git'),
          const _StripButton(icon: Icons.view_list_outlined, tooltip: '구조'),
          const _StripButton(icon: Icons.more_horiz, tooltip: '더 보기'),
          const Spacer(),
          const _StripButton(icon: Icons.play_circle_outline, tooltip: '실행'),
          const _StripButton(
            icon: Icons.terminal,
            tooltip: '터미널',
            active: true,
          ),
          const _StripButton(icon: Icons.error_outline, tooltip: '문제'),
          const _StripButton(icon: Icons.call_split, tooltip: '버전 관리'),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _RightToolStrip extends StatelessWidget {
  const _RightToolStrip();

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return Container(
      width: 44,
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: const Column(
        children: [
          SizedBox(height: 6),
          _StripButton(icon: Icons.notifications_none, tooltip: '알림'),
          _StripButton(icon: Icons.people_outline, tooltip: '멤버 ⌘2'),
          _StripButton(icon: Icons.storage_outlined, tooltip: '데이터베이스'),
          _StripButton(icon: Icons.auto_awesome_outlined, tooltip: 'AI 도우미'),
        ],
      ),
    );
  }
}

class _StripButton extends StatelessWidget {
  const _StripButton({
    required this.icon,
    required this.tooltip,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: active ? colors.accent.withValues(alpha: 0.25) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? colors.text : colors.comment,
          ),
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '// 채팅방을 불러오지 못함',
            style: IdeTheme.editor(colors).copyWith(color: colors.comment),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('다시 불러오기')),
        ],
      ),
    );
  }
}
