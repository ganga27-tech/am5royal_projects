import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/admin_stats.dart';
import '../repositories/admin_repository.dart';

class GetAdminStats implements UseCase<AdminStats, NoParams> {
  final AdminRepository repository;

  GetAdminStats(this.repository);

  @override
  Future<Either<Failure, AdminStats>> call(NoParams params) async {
    return await repository.getDashboardStats();
  }
}
