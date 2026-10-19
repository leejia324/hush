import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/platform/screen_cover.dart';
import '../../../core/theme/ide_colors.dart';
import '../../../core/theme/ide_theme.dart';
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
        builder: (context, covered, child) =>
            covered ? const ScreenCover() : child!,
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
      },
      child: Scaffold(
        body: BlocBuilder<ChatCubit, ChatState>(
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
                IdeToolbar(onCover: () => screenCovered.value = true),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ToolStrip(
                        projectPanelOpen: _projectPanelOpen,
                        onToggleProjectPanel: _toggleProjectPanel,
                      ),
                      if (_projectPanelOpen) ...[
                        ProjectPanel(
                          rooms: state.rooms,
                          selectedRoomId: state.selectedRoomId,
                          onSelect: context.read<ChatCubit>().selectRoom,
                          width: _projectPanelWidth,
                        ),
                        PanelResizeHandle(
                          onDrag: _resizeProjectPanel,
                          onDragEnd: _finishResize,
                        ),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            EditorTabBar(fileName: fileName),
                            Expanded(
                              child: ColoredBox(
                                color: colors.editorBackground,
                                child: state.failed
                                    ? _LoadFailed(
                                        onRetry: context.read<ChatCubit>().load,
                                      )
                                    : lines == null
                                    ? const SizedBox.shrink()
                                    : ConversationView(lines: lines),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TerminalComposer(onSend: context.read<ChatCubit>().send),
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
      width: 40,
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          IconButton(
            onPressed: onToggleProjectPanel,
            tooltip: 'Project ⌘1',
            iconSize: 18,
            color: projectPanelOpen ? colors.accent : colors.comment,
            icon: const Icon(Icons.folder_outlined),
          ),
        ],
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
