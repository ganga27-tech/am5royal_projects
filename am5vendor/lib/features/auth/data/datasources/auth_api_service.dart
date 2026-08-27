import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/send_otp_request_model.dart';
import '../models/send_otp_response_model.dart';
import '../models/verify_otp_request_model.dart';
import '../models/verify_otp_response_model.dart';
import '../models/vendor_registration_request_model.dart';
import '../models/vendor_registration_response_model.dart';

class AuthApiService {
  final Dio dio;

  AuthApiService(this.dio);

  String _extractErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet and try again.';
      case DioExceptionType.connectionError:
        return 'Unable to reach server. Please check your internet connection.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        break;
    }

    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data['detail'] != null) return data['detail'].toString();
        if (data['message'] != null) return data['message'].toString();
      } else if (data is String) {
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map) {
            if (parsed['detail'] != null) return parsed['detail'].toString();
            if (parsed['message'] != null) return parsed['message'].toString();
          }
        } catch (_) {}
      }
    }
    return e.message ?? 'Network error. Please try again.';
  }

  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request) async {
    try {
      final response = await dio.post(
        '/auth/vendor/send-otp',
        data: request.toJson(),
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SendOtpResponseModel.fromJson(response.data);
      } else {
        final message =
            response.data?['message'] ??
            response.data?['detail'] ??
            'Failed to send OTP';
        throw ServerException(message.toString());
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<VerifyOtpResponseModel> verifyOtp(
    VerifyOtpRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '/auth/vendor/verify-otp',
        data: request.toJson(),
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return VerifyOtpResponseModel.fromJson(response.data);
      } else {
        final message =
            response.data?['message'] ??
            response.data?['detail'] ??
            'Failed to verify OTP';
        throw ServerException(message.toString());
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<VendorRegistrationResponseModel> registerVendor(
    VendorRegistrationRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '/auth/vendor/register',
        data: request.toJson(),
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return VendorRegistrationResponseModel.fromJson(response.data);
      } else {
        final message =
            response.data?['message'] ??
            response.data?['detail'] ??
            'Failed to register vendor';
        throw ServerException(message.toString());
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }
}
