import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/auth.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
class AuthModel with _$AuthModel {
  const AuthModel._();

  const factory AuthModel({
    required String id,
    required String contact,
    required String token,
    String? name,
    String? email,
    @JsonKey(name: 'profile_photo') String? profilePhoto,
  }) = _AuthModel;

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  Auth toEntity() {
    return Auth(
      id: id,
      contact: contact,
      token: token,
      name: name,
      email: email,
      profilePhoto: profilePhoto,
    );
  }

  factory AuthModel.fromEntity(Auth entity) {
    return AuthModel(
      id: entity.id,
      contact: entity.contact,
      token: entity.token,
      name: entity.name,
      email: entity.email,
      profilePhoto: entity.profilePhoto,
    );
  }
}
