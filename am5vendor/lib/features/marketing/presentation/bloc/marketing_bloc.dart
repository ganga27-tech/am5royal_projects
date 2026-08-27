import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/create_lead.dart';
import '../../domain/usecases/get_leads.dart';
import '../../domain/usecases/get_collaterals.dart';
import 'marketing_event.dart';
import 'marketing_state.dart';

class MarketingBloc extends Bloc<MarketingEvent, MarketingState> {
  final CreateLead createLead;
  final GetLeads getLeads;
  final GetCollaterals getCollaterals;

  MarketingBloc({
    required this.createLead,
    required this.getLeads,
    required this.getCollaterals,
  }) : super(MarketingInitial()) {
    on<FetchMarketingData>(_onFetchMarketingData);
    on<CreateNewLead>(_onCreateNewLead);
  }

  Future<void> _onFetchMarketingData(
    FetchMarketingData event,
    Emitter<MarketingState> emit,
  ) async {
    emit(MarketingLoading());
    
    final leadsResult = await getLeads(GetLeadsParams(
      assignedToMe: event.assignedToMe,
      createdByMe: event.createdByMe,
    ));
    
    final collateralsResult = await getCollaterals(NoParams());

    leadsResult.fold(
      (failure) => emit(MarketingError(message: failure.message)),
      (leads) {
        collateralsResult.fold(
          (failure) => emit(MarketingError(message: failure.message)),
          (collaterals) {
            emit(MarketingLoaded(leads: leads, collaterals: collaterals));
          },
        );
      },
    );
  }

  Future<void> _onCreateNewLead(
    CreateNewLead event,
    Emitter<MarketingState> emit,
  ) async {
    final result = await createLead(CreateLeadParams(leadData: event.leadData));
    
    result.fold(
      (failure) => emit(MarketingError(message: failure.message)),
      (lead) {
        emit(MarketingLeadCreated(lead: lead));
        // Automatically fetch data again
        add(const FetchMarketingData(createdByMe: true));
      },
    );
  }
}
