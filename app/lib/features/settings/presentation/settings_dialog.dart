import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ide_colors.dart';
import '../../../core/theme/ide_theme.dart';
import '../domain/theme_preference.dart';
import 'theme_cubit.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ThemeCubit>(),
        child: const SettingsDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    final ui = IdeTheme.ui(colors).copyWith(fontSize: 13, height: 1.4);
    final divider = Theme.of(context).dividerColor;

    return Dialog(
      backgroundColor: colors.editorBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: divider),
      ),
      child: SizedBox(
        width: 680,
        height: 440,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: divider)),
              ),
              child: Text(
                '설정',
                style: ui.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 200,
                    color: colors.panel,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.selection,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text('모양', style: ui),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '모양',
                            style: ui.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SizedBox(width: 60, child: Text('테마', style: ui)),
                              BlocBuilder<ThemeCubit, ThemePreference>(
                                builder: (context, theme) =>
                                    DropdownButton<ThemePreference>(
                                      value: theme,
                                      style: ui,
                                      dropdownColor: colors.panel,
                                      onChanged: (value) {
                                        if (value != null) {
                                          context.read<ThemeCubit>().select(
                                            value,
                                          );
                                        }
                                      },
                                      items: [
                                        for (final option
                                            in ThemePreference.values)
                                          DropdownMenuItem(
                                            value: option,
                                            child: Text(option.label),
                                          ),
                                      ],
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: divider)),
              ),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
