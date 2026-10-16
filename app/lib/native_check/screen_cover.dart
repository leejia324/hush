import 'package:flutter/material.dart';

/// 화면 가리기 상태. ⌥Space를 누를 때마다 바뀐다.
final screenCovered = ValueNotifier<bool>(false);

/// ⌥Space 등록 결과. 등록 전에는 null이다.
final coverHotKeyRegistered = ValueNotifier<bool?>(null);

/// 화면을 가릴 때 대신 보여 주는 진짜 같은 코드 화면.
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
