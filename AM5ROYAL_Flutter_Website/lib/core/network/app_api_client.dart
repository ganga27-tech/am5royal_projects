import 'api_client.dart';

/// Shared API client for the entire application.
abstract final class AppApiClient {
  static final ApiClient instance = ApiClient();
}
