import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';

abstract class PerfumeLocalDataSource {
  Future<void> cacheAuthToken(String token);
  Future<String?> getAuthToken();
}

const CACHED_AUTH_TOKEN = 'CACHED_AUTH_TOKEN';

class PerfumeLocalDataSourceImpl implements PerfumeLocalDataSource {
  final SharedPreferences sharedPreferences;

  PerfumeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheAuthToken(String token) {
    return sharedPreferences.setString(CACHED_AUTH_TOKEN, token);
  }

  @override
  Future<String?> getAuthToken() {
    final token = sharedPreferences.getString(CACHED_AUTH_TOKEN);
    if (token != null) {
      return Future.value(token);
    } else {
      // This is where you might throw a CacheException if token is required
      // For now, returning null indicates no token
      return Future.value(null);
    }
  }
}