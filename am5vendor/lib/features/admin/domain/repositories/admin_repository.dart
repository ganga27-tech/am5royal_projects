import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_stats.dart';
import '../entities/admin_employee.dart';
import '../entities/admin_vendor.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminStats>> getDashboardStats();
  Future<Either<Failure, List<AdminEmployee>>> getEmployees();
  Future<Either<Failure, List<AdminVendor>>> getVendors({String? searchQuery});
  Future<Either<Failure, void>> updateEmployeeStatus(int id, String status);
  Future<Either<Failure, void>> createEmployee(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateEmployee(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> updateVendorStatus(int id, String status);
  Future<Either<Failure, void>> createVendor(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateVendor(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteVendor(int id);
  Future<Either<Failure, void>> createService(String name, int mainCategoryId, int subCategoryId, String imagePath);
}
