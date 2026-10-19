import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ide_colors.dart';
import '../../../core/theme/ide_theme.dart';
import '../../../core/widgets/ide_controls.dart';
import '../domain/theme_preference.dart';
import 'theme_cubit.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => BlocProvider.value(
        value: context.read<ThemeCubit>(),
        child: const SettingsDialog(),
      ),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _syncWithOs;
  late ThemePreference _manual;

  ThemePreference get _pending =>
      _syncWithOs ? ThemePreference.system : _manual;

  bool get _changed => _pending != context.read<ThemeCubit>().state;

  var _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final current = context.read<ThemeCubit>().state;
    _syncWithOs = current == ThemePreference.system;
    _manual = switch (current) {
      ThemePreference.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? ThemePreference.dark
            : ThemePreference.light,
      _ => current,
    };
  }

  Future<void> _apply() => context.read<ThemeCubit>().select(_pending);

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    final ui = IdeTheme.ui(colors).copyWith(fontSize: 13, height: 1);
    final divider = Theme.of(context).dividerColor;

    return Dialog(
      backgroundColor: colors.editorBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: divider),
      ),
      child: SizedBox(
        width: 760,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 36,
              child: Center(
                child: Text(
                  '설정',
                  style: ui.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Sidebar(colors: colors, style: ui),
                  VerticalDivider(width: 1, color: divider),
                  Expanded(
                    child: _AppearancePage(
                      style: ui,
                      syncWithOs: _syncWithOs,
                      manual: _manual,
                      onSyncChanged: (value) =>
                          setState(() => _syncWithOs = value),
                      onManualChanged: (value) =>
                          setState(() => _manual = value),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: divider)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.lineNumber),
                    ),
                    child: Text('?', style: ui.copyWith(color: colors.comment)),
                  ),
                  const Spacer(),
                  IdeButton(
                    label: '취소',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  IdeButton(
                    label: '적용',
                    onPressed: _changed
                        ? () async {
                            await _apply();
                            if (mounted) setState(() {});
                          }
                        : null,
                  ),
                  const SizedBox(width: 8),
                  IdeButton(
                    label: '확인',
                    primary: true,
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await _apply();
                      navigator.pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.colors, required this.style});

  final IdeColors colors;
  final TextStyle style;

  static const _entries = [
    (depth: 0, label: '모양 및 동작', expanded: true, selected: false),
    (depth: 1, label: '모양', expanded: null, selected: true),
    (depth: 1, label: '메뉴 및 도구 모음', expanded: null, selected: false),
    (depth: 1, label: '시스템 설정', expanded: false, selected: false),
    (depth: 1, label: '알림', expanded: null, selected: false),
    (depth: 0, label: '키맵', expanded: null, selected: false),
    (depth: 0, label: '에디터', expanded: false, selected: false),
    (depth: 0, label: '플러그인', expanded: null, selected: false),
    (depth: 0, label: '버전 관리', expanded: false, selected: false),
    (depth: 0, label: '도구', expanded: false, selected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: colors.panel,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: colors.editorBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: colors.lineNumber),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 14, color: colors.comment),
                const SizedBox(width: 6),
                Text('검색', style: style.copyWith(color: colors.comment)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in _entries)
            Container(
              height: 26,
              padding: EdgeInsets.only(left: 4 + entry.depth * 16.0),
              decoration: BoxDecoration(
                color: entry.selected ? colors.selection : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    child: entry.expanded == null
                        ? null
                        : Icon(
                            entry.expanded!
                                ? Icons.expand_more
                                : Icons.chevron_right,
                            size: 14,
                            color: colors.comment,
                          ),
                  ),
                  Text(entry.label, style: style),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AppearancePage extends StatelessWidget {
  const _AppearancePage({
    required this.style,
    required this.syncWithOs,
    required this.manual,
    required this.onSyncChanged,
    required this.onManualChanged,
  });

  final TextStyle style;
  final bool syncWithOs;
  final ThemePreference manual;
  final ValueChanged<bool> onSyncChanged;
  final ValueChanged<ThemePreference> onManualChanged;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('모양 및 동작  ›  모양', style: style.copyWith(color: colors.comment)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(width: 56, child: Text('테마:', style: style)),
              IdeComboBox<ThemePreference>(
                value: manual,
                items: const [ThemePreference.dark, ThemePreference.light],
                labelOf: (theme) => theme.label,
                onChanged: syncWithOs ? null : onManualChanged,
              ),
              const SizedBox(width: 16),
              IdeCheckbox(
                label: 'OS와 동기화',
                value: syncWithOs,
                onChanged: onSyncChanged,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Text(
              'OS와 동기화를 켜면 macOS의 다크, 라이트 설정을 따름',
              style: style.copyWith(fontSize: 12, color: colors.comment),
            ),
          ),
        ],
      ),
    );
  }
}
