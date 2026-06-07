import 'package:rail_one/core/storage/db/app_local_database.dart';
import 'package:rail_one/core/storage/models/local_user_profile.dart';
import 'package:rail_one/core/storage/models/stored_booking.dart';
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

  Future<String?> getRegisteredMobile() =>
      _prefs.getString(PrefsKeys.registeredMobile);

  Future<String?> getRegisteredEmail() =>
      _prefs.getString(PrefsKeys.registeredEmail);

  Future<double> getRWalletBalance() async =>
      (await _prefs.getDouble(PrefsKeys.rWalletBalance)) ?? 0;

  Future<void> setRWalletBalance(double balance) =>
      _prefs.setDouble(PrefsKeys.rWalletBalance, balance);

  Future<bool> isBiometricLoginEnabled() =>
      _prefs.getBool(PrefsKeys.biometricLoginEnabled, defaultValue: false);

  Future<void> setBiometricLoginEnabled(bool enabled) =>
      _prefs.setBool(PrefsKeys.biometricLoginEnabled, enabled);

  /// Verifies user ID or mobile and password against stored credentials.
  /// Returns null on success; otherwise an error message for the UI.
  Future<String?> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim();
    if (id.isEmpty || password.isEmpty) {
      return 'Please enter User ID / mobile number and password';
    }

    if (!await hasStoredUser()) {
      return 'No account found. Please sign up first.';
    }

    final storedUserId = (await getRegisteredUserId())?.trim();
    final storedMobile = (await getRegisteredMobile())?.trim();
    final profile = await getUserProfile();
    final storedPassword = await getStoredPassword();

    if (storedPassword == null || storedPassword.isEmpty) {
      return 'No account found. Please sign up first.';
    }

    if (!_identifierMatches(
      id,
      storedUserId: storedUserId,
      storedMobile: storedMobile,
      profile: profile,
    )) {
      return 'User ID or mobile number does not match';
    }

    if (storedPassword != password) {
      return 'Incorrect password. Please try again.';
    }

    final userId = storedUserId ?? profile?.id ?? id;
    await Future.wait([
      setLoggedIn(true),
      _securePrefs.write(SecureKeys.password, password),
      saveAuthSession(
        accessToken: 'local_session_$userId',
        refreshToken: 'local_refresh_$userId',
        userId: userId,
      ),
    ]);
    return null;
  }

  bool _identifierMatches(
    String identifier, {
    String? storedUserId,
    String? storedMobile,
    LocalUserProfile? profile,
  }) {
    if (storedUserId != null && identifier == storedUserId) return true;
    if (storedMobile != null && identifier == storedMobile) return true;
    if (profile == null) return false;
    if (identifier == profile.id.trim()) return true;
    final mobile = profile.mobile?.trim();
    return mobile != null && identifier == mobile;
  }

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

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

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

  Future<String> _resolveCurrentUserId() async {
    final userId = await getRegisteredUserId();
    if (_hasText(userId)) return userId!.trim();
    final secureId = await getUserId();
    if (_hasText(secureId)) return secureId!.trim();
    final profile = await getUserProfile();
    if (profile != null && _hasText(profile.id)) return profile.id.trim();
    return 'guest';
  }

  Future<StoredBooking> saveBookingFromPayment({
    required TicketBookingDraft draft,
    required double paidAmount,
    required String paymentMethod,
  }) async {
    final userId = await _resolveCurrentUserId();
    final booking = StoredBooking.fromPayment(
      draft: draft,
      userId: userId,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
    );

    final existing = await _readBookingsForUser(userId);
    final updated = [booking, ...existing];
    await _database.putJsonList(
      boxName: HiveBoxes.cache,
      key: HiveRecordKeys.userBookings(userId),
      value: updated.map((b) => b.toJson()).toList(growable: false),
    );
    return booking;
  }

  Future<List<StoredBooking>> getActiveBookings() async {
    final userId = await _resolveCurrentUserId();
    final all = await _readBookingsForUser(userId);
    final now = DateTime.now();
    final active = all.where((b) => !now.isAfter(b.expiresAt)).toList()
      ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));

    if (active.length != all.length) {
      await _database.putJsonList(
        boxName: HiveBoxes.cache,
        key: HiveRecordKeys.userBookings(userId),
        value: active.map((b) => b.toJson()).toList(growable: false),
      );
    }

    return active;
  }

  Future<List<StoredBooking>> _readBookingsForUser(String userId) async {
    final rows = await _database.getJsonList(
      boxName: HiveBoxes.cache,
      key: HiveRecordKeys.userBookings(userId),
    );
    return rows.map(StoredBooking.fromJson).toList(growable: false);
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
