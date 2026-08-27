import 'package:equatable/equatable.dart';
import '../../data/models/vendor_profile_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final VendorProfileModel profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}
