part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

final class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

final class ProfileUpdated extends ProfileEvent {
  const ProfileUpdated(this.patch);
  final Map<String, dynamic> patch;
  @override
  List<Object?> get props => [patch];
}

final class ProfilePasswordChanged extends ProfileEvent {
  const ProfilePasswordChanged({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;
  @override
  List<Object?> get props => [currentPassword, newPassword];
}

final class ProfileDeleted extends ProfileEvent {
  const ProfileDeleted();
}

final class ProfileMessageCleared extends ProfileEvent {
  const ProfileMessageCleared();
}
