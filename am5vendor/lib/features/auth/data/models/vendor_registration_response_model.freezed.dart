// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_registration_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VendorRegistrationResponseModel _$VendorRegistrationResponseModelFromJson(
    Map<String, dynamic> json) {
  return _VendorRegistrationResponseModel.fromJson(json);
}

/// @nodoc
mixin _$VendorRegistrationResponseModel {
  @JsonKey(name: 'access_token')
  String get accessToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'token_type')
  String get tokenType => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_new_user')
  bool get isNewUser => throw _privateConstructorUsedError;

  /// Serializes this VendorRegistrationResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VendorRegistrationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorRegistrationResponseModelCopyWith<VendorRegistrationResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorRegistrationResponseModelCopyWith<$Res> {
  factory $VendorRegistrationResponseModelCopyWith(
          VendorRegistrationResponseModel value,
          $Res Function(VendorRegistrationResponseModel) then) =
      _$VendorRegistrationResponseModelCopyWithImpl<$Res,
          VendorRegistrationResponseModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'is_new_user') bool isNewUser});
}

/// @nodoc
class _$VendorRegistrationResponseModelCopyWithImpl<$Res,
        $Val extends VendorRegistrationResponseModel>
    implements $VendorRegistrationResponseModelCopyWith<$Res> {
  _$VendorRegistrationResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorRegistrationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? isNewUser = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      isNewUser: null == isNewUser
          ? _value.isNewUser
          : isNewUser // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VendorRegistrationResponseModelImplCopyWith<$Res>
    implements $VendorRegistrationResponseModelCopyWith<$Res> {
  factory _$$VendorRegistrationResponseModelImplCopyWith(
          _$VendorRegistrationResponseModelImpl value,
          $Res Function(_$VendorRegistrationResponseModelImpl) then) =
      __$$VendorRegistrationResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'is_new_user') bool isNewUser});
}

/// @nodoc
class __$$VendorRegistrationResponseModelImplCopyWithImpl<$Res>
    extends _$VendorRegistrationResponseModelCopyWithImpl<$Res,
        _$VendorRegistrationResponseModelImpl>
    implements _$$VendorRegistrationResponseModelImplCopyWith<$Res> {
  __$$VendorRegistrationResponseModelImplCopyWithImpl(
      _$VendorRegistrationResponseModelImpl _value,
      $Res Function(_$VendorRegistrationResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VendorRegistrationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? isNewUser = null,
  }) {
    return _then(_$VendorRegistrationResponseModelImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      isNewUser: null == isNewUser
          ? _value.isNewUser
          : isNewUser // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorRegistrationResponseModelImpl
    implements _VendorRegistrationResponseModel {
  const _$VendorRegistrationResponseModelImpl(
      {@JsonKey(name: 'access_token') required this.accessToken,
      @JsonKey(name: 'token_type') this.tokenType = 'bearer',
      @JsonKey(name: 'is_new_user') this.isNewUser = false});

  factory _$VendorRegistrationResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$VendorRegistrationResponseModelImplFromJson(json);

  @override
  @JsonKey(name: 'access_token')
  final String accessToken;
  @override
  @JsonKey(name: 'token_type')
  final String tokenType;
  @override
  @JsonKey(name: 'is_new_user')
  final bool isNewUser;

  @override
  String toString() {
    return 'VendorRegistrationResponseModel(accessToken: $accessToken, tokenType: $tokenType, isNewUser: $isNewUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorRegistrationResponseModelImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accessToken, tokenType, isNewUser);

  /// Create a copy of VendorRegistrationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorRegistrationResponseModelImplCopyWith<
          _$VendorRegistrationResponseModelImpl>
      get copyWith => __$$VendorRegistrationResponseModelImplCopyWithImpl<
          _$VendorRegistrationResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorRegistrationResponseModelImplToJson(
      this,
    );
  }
}

abstract class _VendorRegistrationResponseModel
    implements VendorRegistrationResponseModel {
  const factory _VendorRegistrationResponseModel(
          {@JsonKey(name: 'access_token') required final String accessToken,
          @JsonKey(name: 'token_type') final String tokenType,
          @JsonKey(name: 'is_new_user') final bool isNewUser}) =
      _$VendorRegistrationResponseModelImpl;

  factory _VendorRegistrationResponseModel.fromJson(Map<String, dynamic> json) =
      _$VendorRegistrationResponseModelImpl.fromJson;

  @override
  @JsonKey(name: 'access_token')
  String get accessToken;
  @override
  @JsonKey(name: 'token_type')
  String get tokenType;
  @override
  @JsonKey(name: 'is_new_user')
  bool get isNewUser;

  /// Create a copy of VendorRegistrationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorRegistrationResponseModelImplCopyWith<
          _$VendorRegistrationResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
