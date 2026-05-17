import 'package:rail_one/core/storage/storage_result.dart';

/// Key-value store for non-sensitive preferences (SharedPreferences).
abstract interface class LocalPrefsStore {
  Future<StorageResult<String?>> getString(String key);
  Future<StorageResult<void>> setString(String key, String value);

  Future<StorageResult<bool?>> getBool(String key);
  Future<StorageResult<void>> setBool(String key, bool value);

  Future<StorageResult<int?>> getInt(String key);
  Future<StorageResult<void>> setInt(String key, int value);

  Future<StorageResult<void>> remove(String key);
  Future<StorageResult<void>> clear();
}
