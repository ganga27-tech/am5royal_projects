part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, saving, ready, error, deleted }

class ProfileState extends Equatable {
  const ProfileState({
    required this.status,
    this.profile,
    this.message,
  });

  const ProfileState.initial() : this(status: ProfileStatus.initial);

  final ProfileStatus status;
  final UserProfile? profile;
  final String? message;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? message,
    bool clearMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, profile, message];
}
