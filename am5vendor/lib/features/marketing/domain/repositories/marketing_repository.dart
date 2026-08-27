import 'package:dartz/dartz.dart';
import '../entities/marketing_lead.dart';
import '../entities/marketing_collateral.dart';
import '../../../../core/error/failures.dart';

abstract class MarketingRepository {
  Future<Either<Failure, MarketingLead>> createLead(Map<String, dynamic> leadData);
  Future<Either<Failure, List<MarketingLead>>> getLeads({bool assignedToMe = false, bool createdByMe = false});
  Future<Either<Failure, List<MarketingCollateral>>> getCollaterals();
}
