import 'package:rail_one/core/storage/db/app_local_database.dart';
import 'package:rail_one/core/storage/models/local_user_profile.dart';
import 'package:rail_one/core/storage/prefs/app_prefs.dart';
import 'package:rail_one/core/storage/prefs/secure_prefs.dart';
import 'package:rail_one/core/storage/storage_keys.dart';

/// Application facade over prefs, secure storage, and local DB.
class LocalStorageService {
  LocalStorageService({
    required AppPrefs prefs,
    required SecurePrefs securePrefs,
    required AppLocalDatabase database,
  }) : _prefs = prefs,
       _securePrefs = securePrefs,
       _database = database;

  final AppPrefs _prefs;
  final SecurePrefs _securePrefs;
  final AppLocalDatabase _database;

  // --- App preferences (SharedPreferences) ---

  Future<bool> isFirstLaunch() =>
      _prefs.getBool(PrefsKeys.isFirstLaunch, defaultValue: true);

  Future<void> setFirstLaunchDone() =>
      _prefs.setBool(PrefsKeys.isFirstLaunch, false);

  Future<String?> getLanguageCode() =>
      _prefs.getString(PrefsKeys.selectedLanguageCode);

  Future<void> setLanguageCode(String code) =>
      _prefs.setString(PrefsKeys.selectedLanguageCode, code);

  Future<String?> getThemeMode() => _prefs.getString(PrefsKeys.themeMode);

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(PrefsKeys.themeMode, mode);

  Future<bool> areNotificationsEnabled() =>
      _prefs.getBool(PrefsKeys.notificationsEnabled, defaultValue: true);

  Future<void> setNotificationsEnabled(bool enabled) =>
      _prefs.setBool(PrefsKeys.notificationsEnabled, enabled);

  // --- Secure session (FlutterSecureStorage) ---

  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await Future.wait([
      _securePrefs.write(SecureKeys.accessToken, accessToken),
      _securePrefs.write(SecureKeys.refreshToken, refreshToken),
      _securePrefs.write(SecureKeys.userId, userId),
    ]);
  }

  Future<String?> getAccessToken() => _securePrefs.read(SecureKeys.accessToken);

  Future<String?> getRefreshToken() =>
      _securePrefs.read(SecureKeys.refreshToken);

  Future<String?> getUserId() => _securePrefs.read(SecureKeys.userId);

  Future<bool> hasActiveSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isLoggedIn() =>
      _prefs.getBool(PrefsKeys.isLoggedIn, defaultValue: false);

  Future<void> setLoggedIn(bool value) =>
      _prefs.setBool(PrefsKeys.isLoggedIn, value);

  /// Persists sign-up credentials across prefs, secure storage, and Hive.
  Future<void> saveRegisteredUser({
    required String name,
    required String mobile,
    required String email,
    required String userId,
    required String password,
  }) async {
    final updatedAt = DateTime.now().toUtc().toIso8601String();

    await Future.wait([
      saveUserProfile(
        LocalUserProfile(
          id: userId,
          displayName: name,
          email: email,
          mobile: mobile,
          updatedAt: updatedAt,
        ),
      ),
      setFirstLaunchDone(),
      setLoggedIn(true),
      _prefs.setString(PrefsKeys.registeredName, name),
      _prefs.setString(PrefsKeys.registeredMobile, mobile),
      _prefs.setString(PrefsKeys.registeredEmail, email),
      _prefs.setString(PrefsKeys.registeredUserId, userId),
      _securePrefs.write(SecureKeys.userId, userId),
      _securePrefs.write(SecureKeys.password, password),
      saveAuthSession(
        accessToken: 'local_session_$userId',
        refreshToken: 'local_refresh_$userId',
        userId: userId,
      ),
    ]);
  }

  Future<String?> getStoredPassword() => _securePrefs.read(SecureKeys.password);

  Future<String?> getRegisteredName() =>
      _prefs.getString(PrefsKeys.registeredName);

  Future<String?> getRegisteredUserId() =>
      _prefs.getString(PrefsKeys.registeredUserId);

  /// True when a user record exists in prefs, secure storage, or the local DB.
  Future<bool> hasStoredUser() async {
    final profile = await getUserProfile();
    if (profile != null &&
        (profile.id.isNotEmpty || profile.displayName.isNotEmpty)) {
      return true;
    }

    final name = await getRegisteredName();
    final userId = await getRegisteredUserId();
    final mobile = await _prefs.getString(PrefsKeys.registeredMobile);
    final email = await _prefs.getString(PrefsKeys.registeredEmail);
    if (_hasText(name) ||
        _hasText(userId) ||
        _hasText(mobile) ||
        _hasText(email)) {
      return true;
    }

    final secureUserId = await getUserId();
    return _hasText(secureUserId);
  }

  bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  Future<void> saveMpin(String mpin) =>
      _securePrefs.write(SecureKeys.mpin, mpin);

  Future<String?> getMpin() => _securePrefs.read(SecureKeys.mpin);

  Future<bool> verifyMpin(String mpin) async {
    final stored = await getMpin();
    if (stored == null || stored.isEmpty) {
      await saveMpin(mpin);
      return true;
    }
    return stored == mpin;
  }

  // --- Structured DB (Hive) ---

  Future<void> saveUserProfile(LocalUserProfile profile) => _database.putJson(
    boxName: HiveBoxes.user,
    key: HiveRecordKeys.userProfile,
    value: profile.toJson(),
  );

  Future<LocalUserProfile?> getUserProfile() async {
    final json = await _database.getJson(
      boxName: HiveBoxes.user,
      key: HiveRecordKeys.userProfile,
    );
    if (json == null) return null;
    return LocalUserProfile.fromJson(json);
  }

  Future<void> saveRecentSearches(List<String> stations) async {
    final payload = stations.map((s) => {'station': s}).toList(growable: false);
    await _database.putJsonList(
      boxName: HiveBoxes.recentSearches,
      key: 'stations',
      value: payload,
    );
  }

  Future<List<String>> getRecentSearches() async {
    final rows = await _database.getJsonList(
      boxName: HiveBoxes.recentSearches,
      key: 'stations',
    );
    return rows
        .map((e) => e['station'] as String?)
        .whereType<String>()
        .toList(growable: false);
  }

  Future<void> clearSession() async {
    await Future.wait([
      _securePrefs.deleteAll(),
      setLoggedIn(false),
      _prefs.remove(PrefsKeys.registeredName),
      _prefs.remove(PrefsKeys.registeredMobile),
      _prefs.remove(PrefsKeys.registeredEmail),
      _prefs.remove(PrefsKeys.registeredUserId),
      _database.clearBox(HiveBoxes.user),
      _database.clearBox(HiveBoxes.cache),
    ]);
  }

  Future<void> clearAll() async {
    await Future.wait([
      clearSession(),
      _database.clearBox(HiveBoxes.recentSearches),
      _prefs.clear(),
    ]);
  }
}
