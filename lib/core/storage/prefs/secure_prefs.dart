import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rail_one/core/errors/storage_exception.dart';

/// Encrypted key-value store for tokens and secrets.
abstract interface class SecurePrefs {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<void> deleteAll();
}

final class FlutterSecurePrefs implements SecurePrefs {
  FlutterSecurePrefs({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    try {
      return _storage.read(key: key);
    } catch (e) {
      throw StorageException('Failed to read secure value for $key', cause: e);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageException('Failed to write secure value for $key', cause: e);
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException('Failed to delete secure value for $key', cause: e);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear secure storage', cause: e);
    }
  }
}
