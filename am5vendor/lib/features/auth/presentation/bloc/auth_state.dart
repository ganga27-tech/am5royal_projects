import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/auth.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  const factory AuthState.loading() = Loading;
  const factory AuthState.success({
    required String message,
    required Auth auth,
  }) = Success;
  const factory AuthState.error(String message) = Error;
}
