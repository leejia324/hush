import 'package:hush/features/lock/domain/lock_image_store.dart';

class MemoryLockImageStore implements LockImageStore {
  @override
  Future<String> save(String sourcePath) async => sourcePath;
}
