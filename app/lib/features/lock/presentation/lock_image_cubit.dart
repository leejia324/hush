import 'package:flutter_bloc/flutter_bloc.dart';

import '../../settings/domain/settings_repository.dart';
import '../domain/lock_image_store.dart';

class LockImageCubit extends Cubit<String?> {
  LockImageCubit(this._settings, this._store, {String? initial})
    : super(initial);

  final SettingsRepository _settings;
  final LockImageStore _store;

  Future<void> use(String sourcePath) async {
    final saved = await _store.save(sourcePath);
    await _settings.saveLockImagePath(saved);
    if (!isClosed) emit(saved);
  }

  Future<void> useDefault() async {
    if (state == null) return;
    await _store.clear();
    await _settings.saveLockImagePath(null);
    if (!isClosed) emit(null);
  }
}
