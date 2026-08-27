// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_otp_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VerifyOtpEvent {
  String get contact => throw _privateConstructorUsedError;
  String get otp => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contact, String otp) submit,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contact, String otp)? submit,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contact, String otp)? submit,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SubmitVerifyOtp value) submit,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubmitVerifyOtp value)? submit,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubmitVerifyOtp value)? submit,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of VerifyOtpEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerifyOtpEventCopyWith<VerifyOtpEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifyOtpEventCopyWith<$Res> {
  factory $VerifyOtpEventCopyWith(
          VerifyOtpEvent value, $Res Function(VerifyOtpEvent) then) =
      _$VerifyOtpEventCopyWithImpl<$Res, VerifyOtpEvent>;
  @useResult
  $Res call({String contact, String otp});
}

/// @nodoc
class _$VerifyOtpEventCopyWithImpl<$Res, $Val extends VerifyOtpEvent>
    implements $VerifyOtpEventCopyWith<$Res> {
  _$VerifyOtpEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerifyOtpEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contact = null,
    Object? otp = null,
  }) {
    return _then(_value.copyWith(
      contact: null == contact
          ? _value.contact
          : contact // ignore: cast_nullable_to_non_nullable
              as String,
      otp: null == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubmitVerifyOtpImplCopyWith<$Res>
    implements $VerifyOtpEventCopyWith<$Res> {
  factory _$$SubmitVerifyOtpImplCopyWith(_$SubmitVerifyOtpImpl value,
          $Res Function(_$SubmitVerifyOtpImpl) then) =
      __$$SubmitVerifyOtpImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String contact, String otp});
}

/// @nodoc
class __$$SubmitVerifyOtpImplCopyWithImpl<$Res>
    extends _$VerifyOtpEventCopyWithImpl<$Res, _$SubmitVerifyOtpImpl>
    implements _$$SubmitVerifyOtpImplCopyWith<$Res> {
  __$$SubmitVerifyOtpImplCopyWithImpl(
      _$SubmitVerifyOtpImpl _value, $Res Function(_$SubmitVerifyOtpImpl) _then)
      : super(_value, _then);

  /// Create a copy of VerifyOtpEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contact = null,
    Object? otp = null,
  }) {
    return _then(_$SubmitVerifyOtpImpl(
      contact: null == contact
          ? _value.contact
          : contact // ignore: cast_nullable_to_non_nullable
              as String,
      otp: null == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SubmitVerifyOtpImpl implements SubmitVerifyOtp {
  const _$SubmitVerifyOtpImpl({required this.contact, required this.otp});

  @override
  final String contact;
  @override
  final String otp;

  @override
  String toString() {
    return 'VerifyOtpEvent.submit(contact: $contact, otp: $otp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitVerifyOtpImpl &&
            (identical(other.contact, contact) || other.contact == contact) &&
            (identical(other.otp, otp) || other.otp == otp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, contact, otp);

  /// Create a copy of VerifyOtpEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitVerifyOtpImplCopyWith<_$SubmitVerifyOtpImpl> get copyWith =>
      __$$SubmitVerifyOtpImplCopyWithImpl<_$SubmitVerifyOtpImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contact, String otp) submit,
  }) {
    return submit(contact, otp);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contact, String otp)? submit,
  }) {
    return submit?.call(contact, otp);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contact, String otp)? submit,
    required TResult orElse(),
  }) {
    if (submit != null) {
      return submit(contact, otp);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SubmitVerifyOtp value) submit,
  }) {
    return submit(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubmitVerifyOtp value)? submit,
  }) {
    return submit?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubmitVerifyOtp value)? submit,
    required TResult orElse(),
  }) {
    if (submit != null) {
      return submit(this);
    }
    return orElse();
  }
}

abstract class SubmitVerifyOtp implements VerifyOtpEvent {
  const factory SubmitVerifyOtp(
      {required final String contact,
      required final String otp}) = _$SubmitVerifyOtpImpl;

  @override
  String get contact;
  @override
  String get otp;

  /// Create a copy of VerifyOtpEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmitVerifyOtpImplCopyWith<_$SubmitVerifyOtpImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
