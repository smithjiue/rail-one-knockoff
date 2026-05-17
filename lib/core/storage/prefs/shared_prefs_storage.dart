import 'package:rail_one/core/errors/storage_exception.dart';
import 'package:rail_one/core/storage/prefs/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SharedPrefsStorage implements AppPrefs {
  SharedPrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      throw StorageException('Failed to read bool for $key', cause: e);
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      throw StorageException('Failed to read int for $key', cause: e);
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      throw StorageException('Failed to read double for $key', cause: e);
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw StorageException('Failed to read string for $key', cause: e);
    }
  }

  @override
  Future<List<String>> getStringList(String key) async {
    try {
      return _prefs.getStringList(key) ?? const [];
    } catch (e) {
      throw StorageException('Failed to read string list for $key', cause: e);
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      return _prefs.setBool(key, value);
    } catch (e) {
      throw StorageException('Failed to write bool for $key', cause: e);
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      return _prefs.setInt(key, value);
    } catch (e) {
      throw StorageException('Failed to write int for $key', cause: e);
    }
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      return _prefs.setDouble(key, value);
    } catch (e) {
      throw StorageException('Failed to write double for $key', cause: e);
    }
  }

  @override
  Future<bool> setString(String key, String value) async {
    try {
      return _prefs.setString(key, value);
    } catch (e) {
      throw StorageException('Failed to write string for $key', cause: e);
    }
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return _prefs.setStringList(key, value);
    } catch (e) {
      throw StorageException('Failed to write string list for $key', cause: e);
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      return _prefs.remove(key);
    } catch (e) {
      throw StorageException('Failed to remove $key', cause: e);
    }
  }

  @override
  Future<bool> clear() async {
    try {
      return _prefs.clear();
    } catch (e) {
      throw StorageException('Failed to clear preferences', cause: e);
    }
  }
}
