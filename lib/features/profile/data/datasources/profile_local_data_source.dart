import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileLocalDataSource {
  Future<void> cacheAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthToken();
}

const CACHED_AUTH_TOKEN = 'CACHED_AUTH_TOKEN';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheAuthToken(String token) {
    return sharedPreferences.setString(CACHED_AUTH_TOKEN, token);
  }

  @override
  Future<String?> getAuthToken() {
    return Future.value(sharedPreferences.getString(CACHED_AUTH_TOKEN));
  }

  @override
  Future<void> clearAuthToken() {
    return sharedPreferences.remove(CACHED_AUTH_TOKEN);
  }
}