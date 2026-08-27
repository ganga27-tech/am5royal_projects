import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/marketing_lead.dart';
import '../repositories/marketing_repository.dart';

class CreateLead implements UseCase<MarketingLead, CreateLeadParams> {
  final MarketingRepository repository;

  CreateLead(this.repository);

  @override
  Future<Either<Failure, MarketingLead>> call(CreateLeadParams params) async {
    return await repository.createLead(params.leadData);
  }
}

class CreateLeadParams {
  final Map<String, dynamic> leadData;

  CreateLeadParams({required this.leadData});
}
