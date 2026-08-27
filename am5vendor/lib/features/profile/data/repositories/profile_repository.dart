import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/vendor_profile_model.dart';

class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository(this.apiClient);

  Future<Either<Failure, VendorProfileModel>> getProfile() async {
    try {
      final response = await apiClient.dio.get('/vendors/me/profile');
      return Right(VendorProfileModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, VendorProfileModel>> updateProfile(VendorProfileModel profile) async {
    try {
      final response = await apiClient.dio.put(
        '/vendors/me/profile',
        data: profile.toJson(),
      );
      return Right(VendorProfileModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
