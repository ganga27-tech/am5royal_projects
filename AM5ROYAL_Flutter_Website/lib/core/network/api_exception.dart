class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;
  final bool isNetworkError;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;

  static ApiException fromResponse(int statusCode, String? detail) {
    final String message = _mapStatusMessage(statusCode, detail);
    return ApiException(message: message, statusCode: statusCode);
  }

  static String _mapStatusMessage(int statusCode, String? detail) {
    if (detail != null && detail.isNotEmpty) {
      return detail;
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your details.';
      case 401:
      case 403:
        return 'Your session has expired. Please login again.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This action conflicts with an existing record.';
      case 422:
        return 'Please check the information you entered.';
      case 500:
        return 'Something went wrong on our end. Please try again.';
      default:
        return 'Request failed. Please try again.';
    }
  }
}
