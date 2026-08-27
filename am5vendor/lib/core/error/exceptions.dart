class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'An unexpected server error occurred.']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'An error occurred while accessing local cache.']);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection.']);

  @override
  String toString() => 'NetworkException: $message';
}
