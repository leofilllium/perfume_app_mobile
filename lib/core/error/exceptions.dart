class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException ($statusCode): $message';
}

class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Failed to retrieve data from cache.'});

  @override
  String toString() => 'CacheException: $message';
}

class UnauthenticatedException implements Exception {
  final String message;
  const UnauthenticatedException({this.message = 'User not authenticated'});
}