enum AiToolStatus {
  success,
  noResults,
  validationError,
  authError,
  serverError,
  timeout,
  networkError,
  unknown,
}

class AiToolResult<T> {
  const AiToolResult({
    required this.status,
    this.data,
    this.userMessage,
  });

  final AiToolStatus status;
  final T? data;
  final String? userMessage;

  bool get isSuccess => status == AiToolStatus.success;

  static AiToolResult<T> ok<T>(T data) => AiToolResult(status: AiToolStatus.success, data: data);

  static AiToolResult<T> fail<T>(AiToolStatus status, String message) =>
      AiToolResult(status: status, userMessage: message);
}
