/// SharedPreferences keys (non-sensitive app state).
abstract final class PrefsKeys {
  static const isFirstLaunch = 'is_first_launch';
  static const isLoggedIn = 'is_logged_in';
  static const selectedLanguageCode = 'selected_language_code';
  static const themeMode = 'theme_mode';
  static const lastSyncAt = 'last_sync_at';
  static const notificationsEnabled = 'notifications_enabled';
  static const registeredName = 'registered_name';
  static const registeredMobile = 'registered_mobile';
  static const registeredEmail = 'registered_email';
  static const registeredUserId = 'registered_user_id';
  static const rWalletBalance = 'r_wallet_balance';
  static const biometricLoginEnabled = 'biometric_login_enabled';
}

/// Secure storage keys (tokens and secrets).
abstract final class SecureKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const userId = 'user_id';
  static const password = 'user_password';
  static const mpin = 'user_mpin';
}

/// Hive box names.
abstract final class HiveBoxes {
  static const user = 'user_box';
  static const cache = 'cache_box';
  static const recentSearches = 'recent_searches_box';
}

/// Record keys inside Hive boxes.
abstract final class HiveRecordKeys {
  static const userProfile = 'user_profile';
  static const homeCache = 'home_cache';
  static String userBookings(String userId) => 'user_bookings_$userId';
}
