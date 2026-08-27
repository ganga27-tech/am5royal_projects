// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'send_otp_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SendOtpResponseModel _$SendOtpResponseModelFromJson(Map<String, dynamic> json) {
  return _SendOtpResponseModel.fromJson(json);
}

/// @nodoc
mixin _$SendOtpResponseModel {
  String get message => throw _privateConstructorUsedError;
  String get identifier => throw _privateConstructorUsedError;

  /// Serializes this SendOtpResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SendOtpResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SendOtpResponseModelCopyWith<SendOtpResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendOtpResponseModelCopyWith<$Res> {
  factory $SendOtpResponseModelCopyWith(SendOtpResponseModel value,
          $Res Function(SendOtpResponseModel) then) =
      _$SendOtpResponseModelCopyWithImpl<$Res, SendOtpResponseModel>;
  @useResult
  $Res call({String message, String identifier});
}

/// @nodoc
class _$SendOtpResponseModelCopyWithImpl<$Res,
        $Val extends SendOtpResponseModel>
    implements $SendOtpResponseModelCopyWith<$Res> {
  _$SendOtpResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SendOtpResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? identifier = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      identifier: null == identifier
          ? _value.identifier
          : identifier // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SendOtpResponseModelImplCopyWith<$Res>
    implements $SendOtpResponseModelCopyWith<$Res> {
  factory _$$SendOtpResponseModelImplCopyWith(_$SendOtpResponseModelImpl value,
          $Res Function(_$SendOtpResponseModelImpl) then) =
      __$$SendOtpResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String identifier});
}

/// @nodoc
class __$$SendOtpResponseModelImplCopyWithImpl<$Res>
    extends _$SendOtpResponseModelCopyWithImpl<$Res, _$SendOtpResponseModelImpl>
    implements _$$SendOtpResponseModelImplCopyWith<$Res> {
  __$$SendOtpResponseModelImplCopyWithImpl(_$SendOtpResponseModelImpl _value,
      $Res Function(_$SendOtpResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SendOtpResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? identifier = null,
  }) {
    return _then(_$SendOtpResponseModelImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      identifier: null == identifier
          ? _value.identifier
          : identifier // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SendOtpResponseModelImpl extends _SendOtpResponseModel {
  const _$SendOtpResponseModelImpl(
      {required this.message, required this.identifier})
      : super._();

  factory _$SendOtpResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SendOtpResponseModelImplFromJson(json);

  @override
  final String message;
  @override
  final String identifier;

  @override
  String toString() {
    return 'SendOtpResponseModel(message: $message, identifier: $identifier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendOtpResponseModelImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.identifier, identifier) ||
                other.identifier == identifier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, identifier);

  /// Create a copy of SendOtpResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendOtpResponseModelImplCopyWith<_$SendOtpResponseModelImpl>
      get copyWith =>
          __$$SendOtpResponseModelImplCopyWithImpl<_$SendOtpResponseModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SendOtpResponseModelImplToJson(
      this,
    );
  }
}

abstract class _SendOtpResponseModel extends SendOtpResponseModel {
  const factory _SendOtpResponseModel(
      {required final String message,
      required final String identifier}) = _$SendOtpResponseModelImpl;
  const _SendOtpResponseModel._() : super._();

  factory _SendOtpResponseModel.fromJson(Map<String, dynamic> json) =
      _$SendOtpResponseModelImpl.fromJson;

  @override
  String get message;
  @override
  String get identifier;

  /// Create a copy of SendOtpResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendOtpResponseModelImplCopyWith<_$SendOtpResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
