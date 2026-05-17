import 'package:hive_flutter/hive_flutter.dart';
import 'package:rail_one/core/storage/local_storage_exception.dart';
import 'package:rail_one/core/storage/storage_keys.dart';
import 'package:rail_one/core/storage/storage_result.dart';
import 'package:rail_one/data/local/db/hive_local_database.dart';

class HiveLocalDatabaseImpl implements HiveLocalDatabase {
  static const _boxNames = [HiveBoxes.user, HiveBoxes.cache];

  bool _initialized = false;

  @override
  Future<StorageResult<void>> init() async {
    if (_initialized) return const StorageSuccess(null);
    try {
      await Hive.initFlutter();
      for (final name in _boxNames) {
        if (!Hive.isBoxOpen(name)) {
          await Hive.openBox<dynamic>(name);
        }
      }
      _initialized = true;
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(
        LocalStorageException('Failed to initialize Hive', cause: e),
      );
    }
  }

  Box<dynamic> _box(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw LocalStorageException('Hive box "$boxName" is not open');
    }
    return Hive.box<dynamic>(boxName);
  }

  @override
  Future<StorageResult<void>> putJson({
    required String boxName,
    required String key,
    required Map<String, dynamic> value,
  }) async {
    try {
      await _box(boxName).put(key, value);
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(_exception('put', boxName, key, e));
    }
  }

  @override
  Future<StorageResult<Map<String, dynamic>?>> getJson({
    required String boxName,
    required String key,
  }) async {
    try {
      final raw = _box(boxName).get(key);
      if (raw == null) return const StorageSuccess(null);
      return StorageSuccess(Map<String, dynamic>.from(raw as Map));
    } catch (e) {
      return StorageFailure(_exception('get', boxName, key, e));
    }
  }

  @override
  Future<StorageResult<void>> putJsonList({
    required String boxName,
    required String key,
    required List<Map<String, dynamic>> value,
  }) async {
    try {
      await _box(boxName).put(key, value);
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(_exception('put list', boxName, key, e));
    }
  }

  @override
  Future<StorageResult<List<Map<String, dynamic>>>> getJsonList({
    required String boxName,
    required String key,
  }) async {
    try {
      final raw = _box(boxName).get(key);
      if (raw == null) return const StorageSuccess([]);
      final list = (raw as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return StorageSuccess(list);
    } catch (e) {
      return StorageFailure(_exception('get list', boxName, key, e));
    }
  }

  @override
  Future<StorageResult<void>> delete({
    required String boxName,
    required String key,
  }) async {
    try {
      await _box(boxName).delete(key);
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(_exception('delete', boxName, key, e));
    }
  }

  @override
  Future<StorageResult<void>> clearBox(String boxName) async {
    try {
      await _box(boxName).clear();
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(
        LocalStorageException('Failed to clear box "$boxName"', cause: e),
      );
    }
  }

  @override
  Future<StorageResult<void>> clearAll() async {
    try {
      for (final name in _boxNames) {
        if (Hive.isBoxOpen(name)) {
          await Hive.box<dynamic>(name).clear();
        }
      }
      return const StorageSuccess(null);
    } catch (e) {
      return StorageFailure(
        LocalStorageException('Failed to clear all Hive boxes', cause: e),
      );
    }
  }

  LocalStorageException _exception(
    String action,
    String boxName,
    String key,
    Object cause,
  ) {
    return LocalStorageException(
      'Failed to $action in "$boxName" for key "$key"',
      cause: cause,
    );
  }
}
