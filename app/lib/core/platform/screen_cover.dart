import 'package:flutter/material.dart';

import '../theme/ide_colors.dart';
import '../theme/ide_theme.dart';

final screenCovered = ValueNotifier<bool>(false);

final coverHotKeyRegistered = ValueNotifier<bool?>(null);

class ScreenCover extends StatelessWidget {
  const ScreenCover({super.key});

  static const _code = '''
package notes.data

import notes.core.Note
import notes.core.NoteDao

class NoteRepository(
    private val dao: NoteDao,
) {
    suspend fun findAll(): List<Note> = dao.findAll()

    suspend fun save(note: Note) {
        dao.upsert(note.copy(updatedAt = System.currentTimeMillis()))
    }

    suspend fun delete(id: Long) = dao.deleteById(id)
}
''';

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return ColoredBox(
      color: colors.editorBackground,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(_code, style: IdeTheme.code(colors)),
        ),
      ),
    );
  }
}
