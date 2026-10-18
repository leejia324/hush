import 'package:flutter/material.dart';

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
    return const ColoredBox(
      color: Color(0xFF1E1F22),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            _code,
            style: TextStyle(
              color: Color(0xFFDFE1E5),
              fontFamily: 'Menlo',
              fontSize: 14,
              height: 24 / 14,
            ),
          ),
        ),
      ),
    );
  }
}
