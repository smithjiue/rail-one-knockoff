import 'package:flutter_test/flutter_test.dart';
import 'package:rail_one/core/storage/db/app_local_database.dart';
import 'package:rail_one/core/storage/local_storage_service.dart';
import 'package:rail_one/core/storage/models/local_user_profile.dart';
import 'package:rail_one/core/storage/prefs/app_prefs.dart';
import 'package:rail_one/core/storage/prefs/secure_prefs.dart';

void main() {
  group('LocalStorageService', () {
    late _FakePrefs prefs;
    late _FakeSecurePrefs secure;
    late _FakeDatabase db;
    late LocalStorageService storage;

    setUp(() {
      prefs = _FakePrefs();
      secure = _FakeSecurePrefs();
      db = _FakeDatabase();
      storage = LocalStorageService(
        prefs: prefs,
        securePrefs: secure,
        database: db,
      );
    });

    test('persists language and session', () async {
      await storage.setLanguageCode('hi');
      await storage.saveAuthSession(
        accessToken: 'access',
        refreshToken: 'refresh',
        userId: 'u1',
      );

      expect(await storage.getLanguageCode(), 'hi');
      expect(await storage.getAccessToken(), 'access');
      expect(await storage.hasActiveSession(), isTrue);
    });

    test('persists user profile and recent searches', () async {
      await storage.saveUserProfile(
        const LocalUserProfile(
          id: 'u1',
          displayName: 'Smith',
          email: 'smith@example.com',
        ),
      );
      await storage.saveRecentSearches(['ANDHERI', 'CSMT']);

      final profile = await storage.getUserProfile();
      final searches = await storage.getRecentSearches();

      expect(profile?.displayName, 'Smith');
      expect(searches, ['ANDHERI', 'CSMT']);
    });

    test('persists registered user credentials', () async {
      await storage.saveRegisteredUser(
        name: 'Smith Jiue',
        mobile: '8452817984',
        email: 'smith@example.com',
        userId: 'smith_j',
        password: 'secret12',
      );

      expect(await storage.isLoggedIn(), isTrue);
      expect(await storage.hasStoredUser(), isTrue);
      expect(await storage.getRegisteredName(), 'Smith Jiue');
      expect(await storage.getUserId(), 'smith_j');
      expect(await storage.getStoredPassword(), 'secret12');
      expect((await storage.getUserProfile())?.displayName, 'Smith Jiue');
      expect(await storage.hasActiveSession(), isTrue);
    });

    test('hasStoredUser is false with no persisted user', () async {
      expect(await storage.hasStoredUser(), isFalse);
    });

    test('hasStoredUser is true with only hive profile', () async {
      await storage.saveUserProfile(
        const LocalUserProfile(id: 'u1', displayName: 'Smith'),
      );

      expect(await storage.hasStoredUser(), isTrue);
    });

    test('clearSession removes secure and user data', () async {
      await storage.saveAuthSession(
        accessToken: 'a',
        refreshToken: 'r',
        userId: '1',
      );
      await storage.saveUserProfile(
        const LocalUserProfile(id: '1', displayName: 'A'),
      );

      await storage.clearSession();

      expect(await storage.hasActiveSession(), isFalse);
      expect(await storage.getUserProfile(), isNull);
    });
  });
}

final class _FakePrefs implements AppPrefs {
  final Map<String, Object> _store = {};

  @override
  Future<bool> clear() async {
    _store.clear();
    return true;
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async =>
      _store[key] as bool? ?? defaultValue;

  @override
  Future<double?> getDouble(String key) async => _store[key] as double?;

  @override
  Future<int?> getInt(String key) async => _store[key] as int?;

  @override
  Future<String?> getString(String key) async => _store[key] as String?;

  @override
  Future<List<String>> getStringList(String key) async =>
      List<String>.from(_store[key] as List<String>? ?? const []);

  @override
  Future<bool> remove(String key) async => _store.remove(key) != null;

  @override
  Future<bool> setBool(String key, bool value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _store[key] = List<String>.from(value);
    return true;
  }
}

final class _FakeSecurePrefs implements SecurePrefs {
  final Map<String, String> _store = {};

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<void> deleteAll() async => _store.clear();

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;
}

final class _FakeDatabase implements AppLocalDatabase {
  final Map<String, Map<String, dynamic>> _json = {};
  final Map<String, List<Map<String, dynamic>>> _lists = {};

  @override
  Future<void> clearBox(String boxName) async {
    _json.removeWhere((k, _) => k.startsWith('$boxName:'));
    _lists.removeWhere((k, _) => k.startsWith('$boxName:'));
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> delete({required String boxName, required String key}) async {
    _json.remove('$boxName:$key');
    _lists.remove('$boxName:$key');
  }

  @override
  Future<Map<String, dynamic>?> getJson({
    required String boxName,
    required String key,
  }) async =>
      _json['$boxName:$key'];

  @override
  Future<List<Map<String, dynamic>>> getJsonList({
    required String boxName,
    required String key,
  }) async =>
      _lists['$boxName:$key'] ?? const [];

  @override
  Future<void> init() async {}

  @override
  Future<void> putJson({
    required String boxName,
    required String key,
    required Map<String, dynamic> value,
  }) async {
    _json['$boxName:$key'] = value;
  }

  @override
  Future<void> putJsonList({
    required String boxName,
    required String key,
    required List<Map<String, dynamic>> value,
  }) async {
    _lists['$boxName:$key'] = value;
  }
}
