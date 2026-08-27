import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/admin_vendor.dart';
import '../repositories/admin_repository.dart';

class GetAdminVendorsParams {
  final String? searchQuery;

  GetAdminVendorsParams({this.searchQuery});
}

class GetAdminVendors implements UseCase<List<AdminVendor>, GetAdminVendorsParams> {
  final AdminRepository repository;

  GetAdminVendors(this.repository);

  @override
  Future<Either<Failure, List<AdminVendor>>> call(GetAdminVendorsParams params) async {
    return await repository.getVendors(searchQuery: params.searchQuery);
  }
}
