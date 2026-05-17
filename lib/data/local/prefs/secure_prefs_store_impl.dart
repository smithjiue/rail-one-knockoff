import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rail_one/core/storage/local_storage_exception.dart';
import 'package:rail_one/core/storage/storage_result.dart';
import 'package:rail_one/data/local/prefs/secure_prefs_store.dart';

class SecurePrefsStoreImpl implements SecurePrefsStore {
  SecurePrefsStoreImpl({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<StorageResult<String?>> read(String key) async {
    try {
      return StorageSuccess(await _storage.read(key: key));
    } catch (e) {
      return StorageFailure(_exception('read', key, e));
    }
  }

  @override
  Future<StorageResult<void>> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(_exception('write', key, e));
    }
  }

  @override
  Future<StorageResult<void>> delete(String key) async {
    try {
      await _storage.delete(key: key);
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(_exception('delete', key, e));
    }
  }

  @override
  Future<StorageResult<void>> deleteAll() async {
    try {
      await _storage.deleteAll();
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(
        LocalStorageException('Failed to clear secure storage', cause: e),
      );
    }
  }

  LocalStorageException _exception(String action, String key, Object cause) {
    return LocalStorageException(
      'Failed to $action secure key "$key"',
      cause: cause,
    );
  }
}
