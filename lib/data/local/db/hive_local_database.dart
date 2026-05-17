import 'package:rail_one/core/storage/storage_result.dart';

/// Structured local database backed by Hive boxes.
abstract interface class HiveLocalDatabase {
  Future<StorageResult<void>> init();

  Future<StorageResult<void>> putJson({
    required String boxName,
    required String key,
    required Map<String, dynamic> value,
  });

  Future<StorageResult<Map<String, dynamic>?>> getJson({
    required String boxName,
    required String key,
  });

  Future<StorageResult<void>> putJsonList({
    required String boxName,
    required String key,
    required List<Map<String, dynamic>> value,
  });

  Future<StorageResult<List<Map<String, dynamic>>>> getJsonList({
    required String boxName,
    required String key,
  });

  Future<StorageResult<void>> delete({
    required String boxName,
    required String key,
  });

  Future<StorageResult<void>> clearBox(String boxName);
  Future<StorageResult<void>> clearAll();
}
