import 'package:hive_flutter/hive_flutter.dart';
import 'package:rail_one/core/errors/storage_exception.dart';
import 'package:rail_one/core/storage/db/app_local_database.dart';
import 'package:rail_one/core/storage/storage_keys.dart';

final class HiveLocalDatabase implements AppLocalDatabase {
  static const _jsonListSuffix = '__json_list__';

  final Map<String, Box<dynamic>> _boxes = {};
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();
      await Future.wait([
        _openBox(HiveBoxes.user),
        _openBox(HiveBoxes.cache),
        _openBox(HiveBoxes.recentSearches),
      ]);
      _initialized = true;
    } catch (e) {
      throw StorageException('Failed to initialize Hive', cause: e);
    }
  }

  Future<void> _openBox(String name) async {
    if (_boxes.containsKey(name)) return;
    _boxes[name] = await Hive.openBox<dynamic>(name);
  }

  Box<dynamic> _box(String boxName) {
    final box = _boxes[boxName];
    if (box == null || !box.isOpen) {
      throw StorageException('Hive box "$boxName" is not open');
    }
    return box;
  }

  @override
  Future<void> putJson({
    required String boxName,
    required String key,
    required Map<String, dynamic> value,
  }) async {
    try {
      await _box(boxName).put(key, value);
    } catch (e) {
      throw StorageException(
        'Failed to write record $key in $boxName',
        cause: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getJson({
    required String boxName,
    required String key,
  }) async {
    try {
      final raw = await _box(boxName).get(key);
      if (raw == null) return null;
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
      throw StorageException('Invalid JSON map type for $key in $boxName');
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        'Failed to read record $key from $boxName',
        cause: e,
      );
    }
  }

  @override
  Future<void> putJsonList({
    required String boxName,
    required String key,
    required List<Map<String, dynamic>> value,
  }) async {
    try {
      await _box(boxName).put('$_jsonListSuffix$key', value);
    } catch (e) {
      throw StorageException(
        'Failed to write list $key in $boxName',
        cause: e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getJsonList({
    required String boxName,
    required String key,
  }) async {
    try {
      final raw = await _box(boxName).get('$_jsonListSuffix$key');
      if (raw == null) return const [];

      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
      }
      throw StorageException('Invalid JSON list type for $key in $boxName');
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        'Failed to read list $key from $boxName',
        cause: e,
      );
    }
  }

  @override
  Future<void> delete({
    required String boxName,
    required String key,
  }) async {
    try {
      final box = _box(boxName);
      await box.delete(key);
      await box.delete('$_jsonListSuffix$key');
    } catch (e) {
      throw StorageException(
        'Failed to delete $key from $boxName',
        cause: e,
      );
    }
  }

  @override
  Future<void> clearBox(String boxName) async {
    try {
      await _box(boxName).clear();
    } catch (e) {
      throw StorageException('Failed to clear box $boxName', cause: e);
    }
  }

  @override
  Future<void> close() async {
    for (final box in _boxes.values) {
      if (box.isOpen) {
        await box.close();
      }
    }
    _boxes.clear();
    _initialized = false;
  }
}
