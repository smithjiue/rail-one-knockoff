import 'package:rail_one/core/storage/storage_result.dart';

/// Encrypted key-value store for tokens and secrets.
abstract interface class SecurePrefsStore {
  Future<StorageResult<String?>> read(String key);
  Future<StorageResult<void>> write(String key, String value);
  Future<StorageResult<void>> delete(String key);
  Future<StorageResult<void>> deleteAll();
}
