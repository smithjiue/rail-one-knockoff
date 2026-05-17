/// Structured local database (Hive boxes) for objects and lists.
abstract interface class AppLocalDatabase {
  Future<void> init();

  Future<void> putJson({
    required String boxName,
    required String key,
    required Map<String, dynamic> value,
  });

  Future<Map<String, dynamic>?> getJson({
    required String boxName,
    required String key,
  });

  Future<void> putJsonList({
    required String boxName,
    required String key,
    required List<Map<String, dynamic>> value,
  });

  Future<List<Map<String, dynamic>>> getJsonList({
    required String boxName,
    required String key,
  });

  Future<void> delete({
    required String boxName,
    required String key,
  });

  Future<void> clearBox(String boxName);

  Future<void> close();
}
