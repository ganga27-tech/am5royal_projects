import 'package:equatable/equatable.dart';

abstract class MarketingEvent extends Equatable {
  const MarketingEvent();

  @override
  List<Object?> get props => [];
}

class FetchMarketingData extends MarketingEvent {
  final bool assignedToMe;
  final bool createdByMe;

  const FetchMarketingData({this.assignedToMe = false, this.createdByMe = false});

  @override
  List<Object?> get props => [assignedToMe, createdByMe];
}

class CreateNewLead extends MarketingEvent {
  final Map<String, dynamic> leadData;

  const CreateNewLead(this.leadData);

  @override
  List<Object?> get props => [leadData];
}
