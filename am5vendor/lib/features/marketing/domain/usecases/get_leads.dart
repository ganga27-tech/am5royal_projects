import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/marketing_lead.dart';
import '../repositories/marketing_repository.dart';

class GetLeads implements UseCase<List<MarketingLead>, GetLeadsParams> {
  final MarketingRepository repository;

  GetLeads(this.repository);

  @override
  Future<Either<Failure, List<MarketingLead>>> call(GetLeadsParams params) async {
    return await repository.getLeads(
      assignedToMe: params.assignedToMe,
      createdByMe: params.createdByMe,
    );
  }
}

class GetLeadsParams {
  final bool assignedToMe;
  final bool createdByMe;

  GetLeadsParams({this.assignedToMe = false, this.createdByMe = false});
}
