import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class KycApi {
  KycApi(this._client);

  final ApiClient _client;

  Future<KycStatus> getStatus() async {
    try {
      final response = await _client.dio.get('/partner/kyc');
      return KycStatus.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<KycDocument> submitDocument({
    required String docType,
    required String fileUrl,
    String? fileName,
    String? notes,
  }) async {
    try {
      final response = await _client.dio.post(
        '/partner/kyc/documents',
        data: {
          'doc_type': docType,
          'file_url': fileUrl,
          if (fileName != null) 'file_name': fileName,
          if (notes != null) 'notes': notes,
        },
      );
      return KycDocument.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }
}
