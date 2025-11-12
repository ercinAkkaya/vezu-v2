import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUserId(String userId);
  Future<String?> getCachedUserId();
  Future<void> clearCachedUserId();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._preferences);

  static const _userIdKey = 'auth_user_id';

  final SharedPreferences _preferences;

  @override
  Future<void> cacheUserId(String userId) async {
    await _preferences.setString(_userIdKey, userId);
  }

  @override
  Future<String?> getCachedUserId() async {
    return _preferences.getString(_userIdKey);
  }

  @override
  Future<void> clearCachedUserId() async {
    await _preferences.remove(_userIdKey);
  }
}

