import 'package:get_it/get_it.dart';
import 'package:rail_one/core/auth/biometric_auth_service.dart';
import 'package:rail_one/core/storage/db/app_local_database.dart';
import 'package:rail_one/core/storage/db/hive_local_database.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/storage/prefs/app_prefs.dart';
import 'package:rail_one/core/storage/prefs/secure_prefs.dart';
import 'package:rail_one/core/storage/prefs/shared_prefs_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

/// Initializes Hive, SharedPreferences, secure storage, and registers singletons.
Future<void> configureDependencies() async {
  if (sl.isRegistered<LocalStorageService>()) return;

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<AppPrefs>(SharedPrefsStorage(sharedPreferences));

  sl.registerLazySingleton<SecurePrefs>(FlutterSecurePrefs.new);

  final database = HiveLocalDatabase();
  await database.init();
  sl.registerSingleton<AppLocalDatabase>(database);

  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(
      prefs: sl<AppPrefs>(),
      securePrefs: sl<SecurePrefs>(),
      database: sl<AppLocalDatabase>(),
    ),
  );

  sl.registerLazySingleton<BiometricAuthService>(BiometricAuthService.new);
}

/// Closes Hive boxes. Call on app dispose if needed.
Future<void> resetDependencies() async {
  if (sl.isRegistered<AppLocalDatabase>()) {
    await sl<AppLocalDatabase>().close();
  }
  await sl.reset();
}
