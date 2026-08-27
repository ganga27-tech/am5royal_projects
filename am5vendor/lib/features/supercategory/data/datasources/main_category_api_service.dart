import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/error/exceptions.dart';
import '../models/main_category_model.dart';
import '../models/subcategory_model.dart';
import '../models/service_model.dart';
import '../models/add_service_request_model.dart';
import '../models/add_service_response_model.dart';

class MainCategoryApiService {
  final Dio dio;

  MainCategoryApiService(this.dio);

  Future<List<MainCategoryModel>> getMainCategories() async {
    try {
      final response = await dio.get(
        '/vendor/catalog/main-categories',
        options: Options(headers: {'accept': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data as List<dynamic>;
        return list
            .map(
              (json) =>
                  MainCategoryModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        final message =
            response.data?['message'] ?? 'Failed to load main categories';
        throw ServerException(message.toString());
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(message.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<SubCategoryModel>> getSubCategories(int categoryId) async {
    try {
      final response = await dio.get(
        '/vendor/catalog/main-categories/$categoryId/sub-categories',
        options: Options(headers: {'accept': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data as List<dynamic>;
        return list
            .map(
              (json) => SubCategoryModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        final message =
            response.data?['message'] ?? 'Failed to load subcategories';
        throw ServerException(message.toString());
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(message.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<ServiceModel>> getServices({
    required int mainCategoryId,
    int? subCategoryId,
  }) async {
    try {
      final queryParams = {
        'main_category_id': mainCategoryId,
        if (subCategoryId != null) 'subcategory_id': subCategoryId,
        'skip': 0,
        'limit': 100,
      };

      final response = await dio.get(
        '/catalog/services',
        queryParameters: queryParams,
        options: Options(headers: {'accept': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data as List<dynamic>;
        return list
            .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final message = response.data?['message'] ?? 'Failed to load services';
        throw ServerException(message.toString());
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(message.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<AddServiceResponseModel> addService({
    required int serviceId,
    required double amount,
    required bool isNegotiable,
    List<MediaItemModel> media = const [],
  }) async {
    try {
      final requestModel = AddServiceRequestModel(
        serviceId: serviceId,
        amount: amount,
        isNegotiable: isNegotiable,
        media: media,
      );
      final response = await dio.post(
        '/vendor/catalog/add-service',
        data: requestModel.toJson(),
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddServiceResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        final message = response.data?['message'] ?? 'Failed to add service';
        throw ServerException(message.toString());
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(message.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> removeService(int serviceId) async {
    try {
      final response = await dio.delete(
        '/vendor/catalog/remove-service/$serviceId',
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        final message = response.data?['message'] ?? 'Failed to remove service';
        throw ServerException(message.toString());
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(message.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> removeSubCategory(int subCategoryId) async {
    try {
      final response = await dio.delete(
        '/vendor/catalog/remove-subcategory/$subCategoryId',
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        final message = response.data?['message'] ?? 'Failed to remove subcategory services';
        throw ServerException(message.toString());
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(message.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Called when vendor taps PROCEED after adding services — triggers KYC push notification.
  Future<Map<String, dynamic>> completeServiceSelection() async {
    try {
      final response = await dio.post(
        '/vendor/catalog/complete-service-selection',
        options: Options(headers: {'accept': 'application/json'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      final message =
          response.data?['message'] ?? 'Failed to complete service selection';
      throw ServerException(message.toString());
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(message.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<MediaItemModel> uploadMedia(XFile file) async {
    try {
      final uploadFile = file;

      String fileName = uploadFile.name.trim();
      String? mimeType = uploadFile.mimeType;

      // Determine extension from mimeType or path
      String ext = 'jpg';
      if (mimeType != null) {
        if (mimeType.contains('png')) {
          ext = 'png';
        } else if (mimeType.contains('gif')) {
          ext = 'gif';
        } else if (mimeType.contains('pdf')) {
          ext = 'pdf';
        } else if (mimeType.contains('mp4')) {
          ext = 'mp4';
        } else if (mimeType.contains('quicktime') || mimeType.contains('mov')) {
          ext = 'mov';
        } else if (mimeType.contains('3gpp') || mimeType.contains('3gp')) {
          ext = '3gp';
        } else if (mimeType.contains('webm')) {
          ext = 'webm';
        } else if (mimeType.contains('jpeg') || mimeType.contains('jpg')) {
          ext = 'jpg';
        }
      } else {
        // Fallback: extract extension from file path
        final pathLower = uploadFile.path.toLowerCase();
        if (pathLower.endsWith('.png')) {
          ext = 'png';
        } else if (pathLower.endsWith('.gif')) {
          ext = 'gif';
        } else if (pathLower.endsWith('.pdf')) {
          ext = 'pdf';
        } else if (pathLower.endsWith('.mp4')) {
          ext = 'mp4';
        } else if (pathLower.endsWith('.mov')) {
          ext = 'mov';
        } else if (pathLower.endsWith('.3gp')) {
          ext = '3gp';
        } else if (pathLower.endsWith('.webm')) {
          ext = 'webm';
        } else if (pathLower.endsWith('.jpg') || pathLower.endsWith('.jpeg')) {
          ext = 'jpg';
        }
      }

      if (fileName.isEmpty) {
        fileName = 'upload.$ext';
      } else if (!fileName.contains('.')) {
        fileName = '$fileName.$ext';
      }

      // Resolve MediaType
      MediaType parsedContentType;
      const videoExts = {'mp4', 'mov', '3gp', 'webm'};
      if (videoExts.contains(ext)) {
        // Correct MIME type for each video format
        final videoSubtype = ext == 'mov' ? 'quicktime' : (ext == '3gp' ? '3gpp' : ext);
        parsedContentType = MediaType('video', videoSubtype);
      } else if (mimeType != null && mimeType.isNotEmpty) {
        try {
          final parsed = MediaType.parse(mimeType);
          if (parsed.type == 'image' || parsed.type == 'video') {
            parsedContentType = parsed;
          } else {
            parsedContentType = MediaType('image', 'jpeg');
          }
        } catch (_) {
          parsedContentType = MediaType('image', 'jpeg');
        }
      } else {
        parsedContentType = MediaType('image', ext == 'png' ? 'png' : 'jpeg');
      }

      FormData formData;
      if (kIsWeb) {
        final bytes = await uploadFile.readAsBytes();
        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: parsedContentType,
          ),
        });
      } else {
        formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(
            uploadFile.path,
            filename: fileName,
            contentType: parsedContentType,
          ),
        });
      }

      final response = await dio.post(
        '/media/upload',
        data: formData,
        options: Options(
          // Per-request extended timeout for large file uploads
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes: 10),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MediaItemModel(
          mediaUrl: (response.data['url'] ?? '') as String,
          mediaType: (response.data['media_type'] ?? 'image') as String,
        );
      } else {
        final detail = response.data?['detail'];
        String msg = 'Failed to upload media. Please try again.';
        if (detail is String && detail.isNotEmpty) {
          msg = detail;
        } else if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) {
            msg = first['msg'].toString();
          } else {
            msg = first.toString();
          }
        }
        throw ServerException(msg);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw ServerException(
            'Upload timed out. Please check your internet connection and try again.');
      }
      final responseData = e.response?.data;
      String message = 'Media upload failed (${e.response?.statusCode ?? 'network'}). Please try again.';
      if (responseData is Map) {
        final detail = responseData['detail'] ?? responseData['message'] ?? responseData['error'];
        if (detail is String && detail.isNotEmpty) {
          message = detail;
        } else if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) {
            message = first['msg'].toString();
          } else {
            message = first.toString();
          }
        }
      } else if (responseData is String && responseData.isNotEmpty) {
        message = responseData;
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }
      throw ServerException(message);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to upload media: ${e.toString()}');
    }
  }
}
