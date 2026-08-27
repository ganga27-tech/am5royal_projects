import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/marketing_lead.dart';
import '../../domain/entities/marketing_collateral.dart';
import '../../domain/repositories/marketing_repository.dart';
import '../datasources/marketing_remote_data_source.dart';

class MarketingRepositoryImpl implements MarketingRepository {
  final MarketingRemoteDataSource remoteDataSource;

  MarketingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MarketingLead>> createLead(Map<String, dynamic> leadData) async {
    try {
      final lead = await remoteDataSource.createLead(leadData);
      return Right(lead);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<MarketingLead>>> getLeads({bool assignedToMe = false, bool createdByMe = false}) async {
    try {
      final leads = await remoteDataSource.getLeads(
        assignedToMe: assignedToMe,
        createdByMe: createdByMe,
      );
      return Right(leads);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<MarketingCollateral>>> getCollaterals() async {
    try {
      final collaterals = await remoteDataSource.getCollaterals();
      return Right(collaterals);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
