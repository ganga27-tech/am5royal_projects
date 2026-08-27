import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_model.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/auth_storage_service.dart';
import '../models/send_otp_request_model.dart';
import '../models/send_otp_response_model.dart';
import '../models/verify_otp_request_model.dart';
import '../models/verify_otp_response_model.dart';
import '../models/vendor_registration_request_model.dart';
import '../models/vendor_registration_response_model.dart';
import '../models/vendor_business_details_request_model.dart';
import 'auth_api_service.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> loginWithOtp({
    required String contact,
    required String otp,
  });

  Future<AuthModel> loginWithGoogle();

  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request);

  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpRequestModel request);

  Future<VendorRegistrationResponseModel> registerVendor(
    VendorRegistrationRequestModel request,
  );

  Future<void> submitBusinessDetails(
    VendorBusinessDetailsRequestModel request,
  );

  Future<void> deleteAccount();

  Future<AuthModel> loginEmployee({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final AuthApiService authApiService;

  AuthRemoteDataSourceImpl(this.apiClient, this.authApiService);

  String _extractErrorMessage(DioException e) {
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
    // Fallback if parsing fails, avoid the extremely long Dio default message
    return 'Server error: ${e.response?.statusCode ?? "Unknown"}';
  }

  @override
  Future<AuthModel> loginWithOtp({
    required String contact,
    required String otp,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {
          'contact': contact,
          'otp': otp,
        },
      );
      if (response.statusCode == 200) {
        return AuthModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to login');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthModel> loginWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;
      try {
        final googleSignIn = GoogleSignIn();
        googleUser = await googleSignIn.signIn();
      } catch (e) {
        // PlatformException or other setup issues during local development environment
      }

      final response = await apiClient.dio.post('/auth/google');
      if (response.statusCode == 200) {
        final model = AuthModel.fromJson(response.data);
        if (googleUser != null) {
          return model.copyWith(
            name: googleUser.displayName ?? model.name,
            email: googleUser.email,
            profilePhoto: googleUser.photoUrl ?? model.profilePhoto,
          );
        }
        return model;
      } else {
        throw ServerException('Failed to login with Google');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request) async {
    return await authApiService.sendOtp(request);
  }

  @override
  Future<VerifyOtpResponseModel> verifyOtp(
      VerifyOtpRequestModel request) async {
    return await authApiService.verifyOtp(request);
  }

  @override
  Future<VendorRegistrationResponseModel> registerVendor(
      VendorRegistrationRequestModel request) async {
    return await authApiService.registerVendor(request);
  }

  @override
  Future<void> submitBusinessDetails(
      VendorBusinessDetailsRequestModel request) async {
    try {
      final response = await apiClient.dio.post(
        '/vendors/me/business-details',
        data: request.toJson(),
      );
      if (response.statusCode != 200) {
        throw ServerException('Failed to submit business details');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final response = await apiClient.dio.delete('/vendors/me/profile');
      if (response.statusCode != 200) {
        throw ServerException('Failed to delete account');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthModel> loginEmployee({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/employees/login',
        data: {
          'identifier': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['access_token']?.toString() ?? '';
        final role = data['role']?.toString() ?? 'admin';

        // Cache role locally in storage service via DI
        final authStorageService = di.sl<AuthStorageService>();
        await authStorageService.saveUserRole(role);

        return AuthModel(
          id: '1',
          contact: email,
          token: token,
          name: 'Employee',
          email: email,
        );
      } else {
        throw ServerException('Failed to login as employee');
      }
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
