import 'package:rail_one/core/storage/local_storage_exception.dart';
import 'package:rail_one/core/storage/storage_result.dart';
import 'package:rail_one/data/local/prefs/local_prefs_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefsStoreImpl implements LocalPrefsStore {
  LocalPrefsStoreImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<StorageResult<String?>> getString(String key) async {
    try {
      return StorageSuccess(_prefs.getString(key));
    } catch (e) {
      return StorageFailure(_exception('read string', key, e));
    }
  }

  @override
  Future<StorageResult<void>> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(_exception('write string', key, e));
    }
  }

  @override
  Future<StorageResult<bool?>> getBool(String key) async {
    try {
      return StorageSuccess(_prefs.getBool(key));
    } catch (e) {
      return StorageFailure(_exception('read bool', key, e));
    }
  }

  @override
  Future<StorageResult<void>> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(_exception('write bool', key, e));
    }
  }

  @override
  Future<StorageResult<int?>> getInt(String key) async {
    try {
      return StorageSuccess(_prefs.getInt(key));
    } catch (e) {
      return StorageFailure(_exception('read int', key, e));
    }
  }

  @override
  Future<StorageResult<void>> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(_exception('write int', key, e));
    }
  }

  @override
  Future<StorageResult<void>> remove(String key) async {
    try {
      await _prefs.remove(key);
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(_exception('remove', key, e));
    }
  }

  @override
  Future<StorageResult<void>> clear() async {
    try {
      await _prefs.clear();
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(
        LocalStorageException('Failed to clear preferences', cause: e),
      );
    }
  }

  LocalStorageException _exception(String action, String key, Object cause) {
    return LocalStorageException(
      'Failed to $action for key "$key"',
      cause: cause,
    );
  }
}
