import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

typedef TokenExpiredCallback = void Function();

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    TokenStorage? tokenStorage,
  })  : _http = httpClient ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage.instance;

  final http.Client _http;
  final TokenStorage _tokenStorage;

  TokenExpiredCallback? onTokenExpired;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    bool authenticated = false,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: queryParams,
    );
    final response = await _http
        .get(uri, headers: await _headers(authenticated: authenticated))
        .timeout(ApiConfig.receiveTimeout);
    return _handleResponse(response);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? queryParams,
    bool authenticated = false,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: queryParams,
    );
    final response = await _http
        .get(uri, headers: await _headers(authenticated: authenticated))
        .timeout(ApiConfig.receiveTimeout);
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _http
        .post(
          uri,
          headers: await _headers(authenticated: authenticated),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.receiveTimeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _http
        .put(
          uri,
          headers: await _headers(authenticated: authenticated),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.receiveTimeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String fileField,
    required String fileName,
    required List<int> bytes,
    bool authenticated = false,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final request = http.MultipartRequest('POST', uri);

    final headers = await _headers(authenticated: authenticated);
    headers.remove('Content-Type');
    request.headers.addAll(headers);

    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'pdf';
    MediaType mediaType;
    switch (ext) {
      case 'doc':
        mediaType = MediaType('application', 'msword');
        break;
      case 'docx':
        mediaType = MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );
        break;
      default:
        mediaType = MediaType('application', 'pdf');
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        fileField,
        bytes,
        filename: fileName,
        contentType: mediaType,
      ),
    );

    final streamed = await request.send().timeout(ApiConfig.receiveTimeout);
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  Future<Map<String, String>> _headers({required bool authenticated}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final String? token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    _handleAuthError(response.statusCode);
    throw ApiException.fromResponse(
      response.statusCode,
      _extractDetail(response.body),
    );
  }

  List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return [];
      }
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List<dynamic>) {
        return decoded;
      }
      return [];
    }

    _handleAuthError(response.statusCode);
    throw ApiException.fromResponse(
      response.statusCode,
      _extractDetail(response.body),
    );
  }

  void _handleAuthError(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      onTokenExpired?.call();
    }
  }

  String? _extractDetail(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final dynamic detail = decoded['detail'];
        if (detail is String) {
          return detail;
        }
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) {
            return first['msg'].toString();
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
