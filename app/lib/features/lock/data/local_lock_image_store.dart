import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/lock_image_store.dart';

class LocalLockImageStore implements LockImageStore {
  LocalLockImageStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;

  static const _prefix = 'lock_screen_';

  final Future<Directory> Function() _directory;

  @override
  Future<String> save(String sourcePath) async {
    await _clear();
    final directory = await _directory();
    final extension = sourcePath.contains('.')
        ? sourcePath.substring(sourcePath.lastIndexOf('.'))
        : '';
    final target = File(
      '${directory.path}/$_prefix${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  Future<void> _clear() async {
    final directory = await _directory();
    if (!await directory.exists()) return;
    await for (final entity in directory.list()) {
      final name = entity.uri.pathSegments.last;
      if (entity is File && name.startsWith(_prefix)) {
        await entity.delete();
      }
    }
  }
}
