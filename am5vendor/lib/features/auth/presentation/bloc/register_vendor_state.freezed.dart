// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_vendor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RegisterVendorState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VerifyOtpResponse response) success,
    required TResult Function(String message) error,
    required TResult Function(String message) validationError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VerifyOtpResponse response)? success,
    TResult? Function(String message)? error,
    TResult? Function(String message)? validationError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VerifyOtpResponse response)? success,
    TResult Function(String message)? error,
    TResult Function(String message)? validationError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterVendorInitial value) initial,
    required TResult Function(RegisterVendorLoading value) loading,
    required TResult Function(RegisterVendorSuccess value) success,
    required TResult Function(RegisterVendorError value) error,
    required TResult Function(RegisterVendorValidationError value)
        validationError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterVendorInitial value)? initial,
    TResult? Function(RegisterVendorLoading value)? loading,
    TResult? Function(RegisterVendorSuccess value)? success,
    TResult? Function(RegisterVendorError value)? error,
    TResult? Function(RegisterVendorValidationError value)? validationError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterVendorInitial value)? initial,
    TResult Function(RegisterVendorLoading value)? loading,
    TResult Function(RegisterVendorSuccess value)? success,
    TResult Function(RegisterVendorError value)? error,
    TResult Function(RegisterVendorValidationError value)? validationError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterVendorStateCopyWith<$Res> {
  factory $RegisterVendorStateCopyWith(
          RegisterVendorState value, $Res Function(RegisterVendorState) then) =
      _$RegisterVendorStateCopyWithImpl<$Res, RegisterVendorState>;
}

/// @nodoc
class _$RegisterVendorStateCopyWithImpl<$Res, $Val extends RegisterVendorState>
    implements $RegisterVendorStateCopyWith<$Res> {
  _$RegisterVendorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RegisterVendorInitialImplCopyWith<$Res> {
  factory _$$RegisterVendorInitialImplCopyWith(
          _$RegisterVendorInitialImpl value,
          $Res Function(_$RegisterVendorInitialImpl) then) =
      __$$RegisterVendorInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RegisterVendorInitialImplCopyWithImpl<$Res>
    extends _$RegisterVendorStateCopyWithImpl<$Res, _$RegisterVendorInitialImpl>
    implements _$$RegisterVendorInitialImplCopyWith<$Res> {
  __$$RegisterVendorInitialImplCopyWithImpl(_$RegisterVendorInitialImpl _value,
      $Res Function(_$RegisterVendorInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RegisterVendorInitialImpl implements RegisterVendorInitial {
  const _$RegisterVendorInitialImpl();

  @override
  String toString() {
    return 'RegisterVendorState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterVendorInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VerifyOtpResponse response) success,
    required TResult Function(String message) error,
    required TResult Function(String message) validationError,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VerifyOtpResponse response)? success,
    TResult? Function(String message)? error,
    TResult? Function(String message)? validationError,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VerifyOtpResponse response)? success,
    TResult Function(String message)? error,
    TResult Function(String message)? validationError,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterVendorInitial value) initial,
    required TResult Function(RegisterVendorLoading value) loading,
    required TResult Function(RegisterVendorSuccess value) success,
    required TResult Function(RegisterVendorError value) error,
    required TResult Function(RegisterVendorValidationError value)
        validationError,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterVendorInitial value)? initial,
    TResult? Function(RegisterVendorLoading value)? loading,
    TResult? Function(RegisterVendorSuccess value)? success,
    TResult? Function(RegisterVendorError value)? error,
    TResult? Function(RegisterVendorValidationError value)? validationError,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterVendorInitial value)? initial,
    TResult Function(RegisterVendorLoading value)? loading,
    TResult Function(RegisterVendorSuccess value)? success,
    TResult Function(RegisterVendorError value)? error,
    TResult Function(RegisterVendorValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class RegisterVendorInitial implements RegisterVendorState {
  const factory RegisterVendorInitial() = _$RegisterVendorInitialImpl;
}

/// @nodoc
abstract class _$$RegisterVendorLoadingImplCopyWith<$Res> {
  factory _$$RegisterVendorLoadingImplCopyWith(
          _$RegisterVendorLoadingImpl value,
          $Res Function(_$RegisterVendorLoadingImpl) then) =
      __$$RegisterVendorLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RegisterVendorLoadingImplCopyWithImpl<$Res>
    extends _$RegisterVendorStateCopyWithImpl<$Res, _$RegisterVendorLoadingImpl>
    implements _$$RegisterVendorLoadingImplCopyWith<$Res> {
  __$$RegisterVendorLoadingImplCopyWithImpl(_$RegisterVendorLoadingImpl _value,
      $Res Function(_$RegisterVendorLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RegisterVendorLoadingImpl implements RegisterVendorLoading {
  const _$RegisterVendorLoadingImpl();

  @override
  String toString() {
    return 'RegisterVendorState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterVendorLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VerifyOtpResponse response) success,
    required TResult Function(String message) error,
    required TResult Function(String message) validationError,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VerifyOtpResponse response)? success,
    TResult? Function(String message)? error,
    TResult? Function(String message)? validationError,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VerifyOtpResponse response)? success,
    TResult Function(String message)? error,
    TResult Function(String message)? validationError,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterVendorInitial value) initial,
    required TResult Function(RegisterVendorLoading value) loading,
    required TResult Function(RegisterVendorSuccess value) success,
    required TResult Function(RegisterVendorError value) error,
    required TResult Function(RegisterVendorValidationError value)
        validationError,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterVendorInitial value)? initial,
    TResult? Function(RegisterVendorLoading value)? loading,
    TResult? Function(RegisterVendorSuccess value)? success,
    TResult? Function(RegisterVendorError value)? error,
    TResult? Function(RegisterVendorValidationError value)? validationError,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterVendorInitial value)? initial,
    TResult Function(RegisterVendorLoading value)? loading,
    TResult Function(RegisterVendorSuccess value)? success,
    TResult Function(RegisterVendorError value)? error,
    TResult Function(RegisterVendorValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class RegisterVendorLoading implements RegisterVendorState {
  const factory RegisterVendorLoading() = _$RegisterVendorLoadingImpl;
}

/// @nodoc
abstract class _$$RegisterVendorSuccessImplCopyWith<$Res> {
  factory _$$RegisterVendorSuccessImplCopyWith(
          _$RegisterVendorSuccessImpl value,
          $Res Function(_$RegisterVendorSuccessImpl) then) =
      __$$RegisterVendorSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VerifyOtpResponse response});
}

/// @nodoc
class __$$RegisterVendorSuccessImplCopyWithImpl<$Res>
    extends _$RegisterVendorStateCopyWithImpl<$Res, _$RegisterVendorSuccessImpl>
    implements _$$RegisterVendorSuccessImplCopyWith<$Res> {
  __$$RegisterVendorSuccessImplCopyWithImpl(_$RegisterVendorSuccessImpl _value,
      $Res Function(_$RegisterVendorSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? response = null,
  }) {
    return _then(_$RegisterVendorSuccessImpl(
      null == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as VerifyOtpResponse,
    ));
  }
}

/// @nodoc

class _$RegisterVendorSuccessImpl implements RegisterVendorSuccess {
  const _$RegisterVendorSuccessImpl(this.response);

  @override
  final VerifyOtpResponse response;

  @override
  String toString() {
    return 'RegisterVendorState.success(response: $response)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterVendorSuccessImpl &&
            (identical(other.response, response) ||
                other.response == response));
  }

  @override
  int get hashCode => Object.hash(runtimeType, response);

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterVendorSuccessImplCopyWith<_$RegisterVendorSuccessImpl>
      get copyWith => __$$RegisterVendorSuccessImplCopyWithImpl<
          _$RegisterVendorSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VerifyOtpResponse response) success,
    required TResult Function(String message) error,
    required TResult Function(String message) validationError,
  }) {
    return success(response);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VerifyOtpResponse response)? success,
    TResult? Function(String message)? error,
    TResult? Function(String message)? validationError,
  }) {
    return success?.call(response);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VerifyOtpResponse response)? success,
    TResult Function(String message)? error,
    TResult Function(String message)? validationError,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(response);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterVendorInitial value) initial,
    required TResult Function(RegisterVendorLoading value) loading,
    required TResult Function(RegisterVendorSuccess value) success,
    required TResult Function(RegisterVendorError value) error,
    required TResult Function(RegisterVendorValidationError value)
        validationError,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterVendorInitial value)? initial,
    TResult? Function(RegisterVendorLoading value)? loading,
    TResult? Function(RegisterVendorSuccess value)? success,
    TResult? Function(RegisterVendorError value)? error,
    TResult? Function(RegisterVendorValidationError value)? validationError,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterVendorInitial value)? initial,
    TResult Function(RegisterVendorLoading value)? loading,
    TResult Function(RegisterVendorSuccess value)? success,
    TResult Function(RegisterVendorError value)? error,
    TResult Function(RegisterVendorValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class RegisterVendorSuccess implements RegisterVendorState {
  const factory RegisterVendorSuccess(final VerifyOtpResponse response) =
      _$RegisterVendorSuccessImpl;

  VerifyOtpResponse get response;

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterVendorSuccessImplCopyWith<_$RegisterVendorSuccessImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RegisterVendorErrorImplCopyWith<$Res> {
  factory _$$RegisterVendorErrorImplCopyWith(_$RegisterVendorErrorImpl value,
          $Res Function(_$RegisterVendorErrorImpl) then) =
      __$$RegisterVendorErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$RegisterVendorErrorImplCopyWithImpl<$Res>
    extends _$RegisterVendorStateCopyWithImpl<$Res, _$RegisterVendorErrorImpl>
    implements _$$RegisterVendorErrorImplCopyWith<$Res> {
  __$$RegisterVendorErrorImplCopyWithImpl(_$RegisterVendorErrorImpl _value,
      $Res Function(_$RegisterVendorErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$RegisterVendorErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RegisterVendorErrorImpl implements RegisterVendorError {
  const _$RegisterVendorErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'RegisterVendorState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterVendorErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterVendorErrorImplCopyWith<_$RegisterVendorErrorImpl> get copyWith =>
      __$$RegisterVendorErrorImplCopyWithImpl<_$RegisterVendorErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VerifyOtpResponse response) success,
    required TResult Function(String message) error,
    required TResult Function(String message) validationError,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VerifyOtpResponse response)? success,
    TResult? Function(String message)? error,
    TResult? Function(String message)? validationError,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VerifyOtpResponse response)? success,
    TResult Function(String message)? error,
    TResult Function(String message)? validationError,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterVendorInitial value) initial,
    required TResult Function(RegisterVendorLoading value) loading,
    required TResult Function(RegisterVendorSuccess value) success,
    required TResult Function(RegisterVendorError value) error,
    required TResult Function(RegisterVendorValidationError value)
        validationError,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterVendorInitial value)? initial,
    TResult? Function(RegisterVendorLoading value)? loading,
    TResult? Function(RegisterVendorSuccess value)? success,
    TResult? Function(RegisterVendorError value)? error,
    TResult? Function(RegisterVendorValidationError value)? validationError,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterVendorInitial value)? initial,
    TResult Function(RegisterVendorLoading value)? loading,
    TResult Function(RegisterVendorSuccess value)? success,
    TResult Function(RegisterVendorError value)? error,
    TResult Function(RegisterVendorValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class RegisterVendorError implements RegisterVendorState {
  const factory RegisterVendorError(final String message) =
      _$RegisterVendorErrorImpl;

  String get message;

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterVendorErrorImplCopyWith<_$RegisterVendorErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RegisterVendorValidationErrorImplCopyWith<$Res> {
  factory _$$RegisterVendorValidationErrorImplCopyWith(
          _$RegisterVendorValidationErrorImpl value,
          $Res Function(_$RegisterVendorValidationErrorImpl) then) =
      __$$RegisterVendorValidationErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$RegisterVendorValidationErrorImplCopyWithImpl<$Res>
    extends _$RegisterVendorStateCopyWithImpl<$Res,
        _$RegisterVendorValidationErrorImpl>
    implements _$$RegisterVendorValidationErrorImplCopyWith<$Res> {
  __$$RegisterVendorValidationErrorImplCopyWithImpl(
      _$RegisterVendorValidationErrorImpl _value,
      $Res Function(_$RegisterVendorValidationErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$RegisterVendorValidationErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RegisterVendorValidationErrorImpl
    implements RegisterVendorValidationError {
  const _$RegisterVendorValidationErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'RegisterVendorState.validationError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterVendorValidationErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterVendorValidationErrorImplCopyWith<
          _$RegisterVendorValidationErrorImpl>
      get copyWith => __$$RegisterVendorValidationErrorImplCopyWithImpl<
          _$RegisterVendorValidationErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VerifyOtpResponse response) success,
    required TResult Function(String message) error,
    required TResult Function(String message) validationError,
  }) {
    return validationError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VerifyOtpResponse response)? success,
    TResult? Function(String message)? error,
    TResult? Function(String message)? validationError,
  }) {
    return validationError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VerifyOtpResponse response)? success,
    TResult Function(String message)? error,
    TResult Function(String message)? validationError,
    required TResult orElse(),
  }) {
    if (validationError != null) {
      return validationError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RegisterVendorInitial value) initial,
    required TResult Function(RegisterVendorLoading value) loading,
    required TResult Function(RegisterVendorSuccess value) success,
    required TResult Function(RegisterVendorError value) error,
    required TResult Function(RegisterVendorValidationError value)
        validationError,
  }) {
    return validationError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RegisterVendorInitial value)? initial,
    TResult? Function(RegisterVendorLoading value)? loading,
    TResult? Function(RegisterVendorSuccess value)? success,
    TResult? Function(RegisterVendorError value)? error,
    TResult? Function(RegisterVendorValidationError value)? validationError,
  }) {
    return validationError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RegisterVendorInitial value)? initial,
    TResult Function(RegisterVendorLoading value)? loading,
    TResult Function(RegisterVendorSuccess value)? success,
    TResult Function(RegisterVendorError value)? error,
    TResult Function(RegisterVendorValidationError value)? validationError,
    required TResult orElse(),
  }) {
    if (validationError != null) {
      return validationError(this);
    }
    return orElse();
  }
}

abstract class RegisterVendorValidationError implements RegisterVendorState {
  const factory RegisterVendorValidationError(final String message) =
      _$RegisterVendorValidationErrorImpl;

  String get message;

  /// Create a copy of RegisterVendorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterVendorValidationErrorImplCopyWith<
          _$RegisterVendorValidationErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}
