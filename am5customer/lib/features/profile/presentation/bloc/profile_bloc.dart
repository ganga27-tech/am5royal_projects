import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileApi profileApi})
      : _profileApi = profileApi,
        super(const ProfileState.initial()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileUpdated>(_onUpdated);
    on<ProfilePasswordChanged>(_onPassword);
    on<ProfileDeleted>(_onDeleted);
    on<ProfileMessageCleared>(_onClear);
  }

  final ProfileApi _profileApi;

  Future<void> _onStarted(ProfileStarted event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearMessage: true));
    try {
      final profile = await _profileApi.getMe();
      emit(state.copyWith(status: ProfileStatus.ready, profile: profile));
    } on Failure catch (f) {
      emit(state.copyWith(status: ProfileStatus.error, message: f.message));
    }
  }

  Future<void> _onUpdated(ProfileUpdated event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.saving, clearMessage: true));
    try {
      final profile = await _profileApi.updateMe(event.patch);
      emit(state.copyWith(status: ProfileStatus.ready, profile: profile, message: 'saved'));
    } on Failure catch (f) {
      emit(state.copyWith(status: ProfileStatus.ready, message: f.message));
    }
  }

  Future<void> _onPassword(ProfilePasswordChanged event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.saving, clearMessage: true));
    try {
      await _profileApi.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(status: ProfileStatus.ready, message: 'password_changed'));
    } on Failure catch (f) {
      emit(state.copyWith(status: ProfileStatus.ready, message: f.message));
    }
  }

  Future<void> _onDeleted(ProfileDeleted event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.saving, clearMessage: true));
    try {
      await _profileApi.deleteAccount();
      emit(state.copyWith(status: ProfileStatus.deleted, message: 'deleted'));
    } on Failure catch (f) {
      emit(state.copyWith(status: ProfileStatus.ready, message: f.message));
    }
  }

  void _onClear(ProfileMessageCleared event, Emitter<ProfileState> emit) {
    emit(state.copyWith(clearMessage: true));
  }
}
