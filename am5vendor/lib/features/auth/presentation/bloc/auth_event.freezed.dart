// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contact, String otp) verifyAndLogin,
    required TResult Function() loginWithGoogle,
    required TResult Function() checkSession,
    required TResult Function() logout,
    required TResult Function() deleteAccount,
    required TResult Function(String email, String password) loginEmployee,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contact, String otp)? verifyAndLogin,
    TResult? Function()? loginWithGoogle,
    TResult? Function()? checkSession,
    TResult? Function()? logout,
    TResult? Function()? deleteAccount,
    TResult? Function(String email, String password)? loginEmployee,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contact, String otp)? verifyAndLogin,
    TResult Function()? loginWithGoogle,
    TResult Function()? checkSession,
    TResult Function()? logout,
    TResult Function()? deleteAccount,
    TResult Function(String email, String password)? loginEmployee,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VerifyAndLogin value) verifyAndLogin,
    required TResult Function(LoginWithGoogleEvent value) loginWithGoogle,
    required TResult Function(CheckSessionEvent value) checkSession,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(DeleteAccountEvent value) deleteAccount,
    required TResult Function(LoginEmployee value) loginEmployee,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VerifyAndLogin value)? verifyAndLogin,
    TResult? Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult? Function(CheckSessionEvent value)? checkSession,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(DeleteAccountEvent value)? deleteAccount,
    TResult? Function(LoginEmployee value)? loginEmployee,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VerifyAndLogin value)? verifyAndLogin,
    TResult Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult Function(CheckSessionEvent value)? checkSession,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(DeleteAccountEvent value)? deleteAccount,
    TResult Function(LoginEmployee value)? loginEmployee,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthEventCopyWith<$Res> {
  factory $AuthEventCopyWith(AuthEvent value, $Res Function(AuthEvent) then) =
      _$AuthEventCopyWithImpl<$Res, AuthEvent>;
}

/// @nodoc
class _$AuthEventCopyWithImpl<$Res, $Val extends AuthEvent>
    implements $AuthEventCopyWith<$Res> {
  _$AuthEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$VerifyAndLoginImplCopyWith<$Res> {
  factory _$$VerifyAndLoginImplCopyWith(_$VerifyAndLoginImpl value,
          $Res Function(_$VerifyAndLoginImpl) then) =
      __$$VerifyAndLoginImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String contact, String otp});
}

/// @nodoc
class __$$VerifyAndLoginImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$VerifyAndLoginImpl>
    implements _$$VerifyAndLoginImplCopyWith<$Res> {
  __$$VerifyAndLoginImplCopyWithImpl(
      _$VerifyAndLoginImpl _value, $Res Function(_$VerifyAndLoginImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contact = null,
    Object? otp = null,
  }) {
    return _then(_$VerifyAndLoginImpl(
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

class _$VerifyAndLoginImpl implements VerifyAndLogin {
  const _$VerifyAndLoginImpl({required this.contact, required this.otp});

  @override
  final String contact;
  @override
  final String otp;

  @override
  String toString() {
    return 'AuthEvent.verifyAndLogin(contact: $contact, otp: $otp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyAndLoginImpl &&
            (identical(other.contact, contact) || other.contact == contact) &&
            (identical(other.otp, otp) || other.otp == otp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, contact, otp);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyAndLoginImplCopyWith<_$VerifyAndLoginImpl> get copyWith =>
      __$$VerifyAndLoginImplCopyWithImpl<_$VerifyAndLoginImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contact, String otp) verifyAndLogin,
    required TResult Function() loginWithGoogle,
    required TResult Function() checkSession,
    required TResult Function() logout,
    required TResult Function() deleteAccount,
    required TResult Function(String email, String password) loginEmployee,
  }) {
    return verifyAndLogin(contact, otp);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contact, String otp)? verifyAndLogin,
    TResult? Function()? loginWithGoogle,
    TResult? Function()? checkSession,
    TResult? Function()? logout,
    TResult? Function()? deleteAccount,
    TResult? Function(String email, String password)? loginEmployee,
  }) {
    return verifyAndLogin?.call(contact, otp);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contact, String otp)? verifyAndLogin,
    TResult Function()? loginWithGoogle,
    TResult Function()? checkSession,
    TResult Function()? logout,
    TResult Function()? deleteAccount,
    TResult Function(String email, String password)? loginEmployee,
    required TResult orElse(),
  }) {
    if (verifyAndLogin != null) {
      return verifyAndLogin(contact, otp);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VerifyAndLogin value) verifyAndLogin,
    required TResult Function(LoginWithGoogleEvent value) loginWithGoogle,
    required TResult Function(CheckSessionEvent value) checkSession,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(DeleteAccountEvent value) deleteAccount,
    required TResult Function(LoginEmployee value) loginEmployee,
  }) {
    return verifyAndLogin(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VerifyAndLogin value)? verifyAndLogin,
    TResult? Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult? Function(CheckSessionEvent value)? checkSession,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(DeleteAccountEvent value)? deleteAccount,
    TResult? Function(LoginEmployee value)? loginEmployee,
  }) {
    return verifyAndLogin?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VerifyAndLogin value)? verifyAndLogin,
    TResult Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult Function(CheckSessionEvent value)? checkSession,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(DeleteAccountEvent value)? deleteAccount,
    TResult Function(LoginEmployee value)? loginEmployee,
    required TResult orElse(),
  }) {
    if (verifyAndLogin != null) {
      return verifyAndLogin(this);
    }
    return orElse();
  }
}

abstract class VerifyAndLogin implements AuthEvent {
  const factory VerifyAndLogin(
      {required final String contact,
      required final String otp}) = _$VerifyAndLoginImpl;

  String get contact;
  String get otp;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerifyAndLoginImplCopyWith<_$VerifyAndLoginImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoginWithGoogleEventImplCopyWith<$Res> {
  factory _$$LoginWithGoogleEventImplCopyWith(_$LoginWithGoogleEventImpl value,
          $Res Function(_$LoginWithGoogleEventImpl) then) =
      __$$LoginWithGoogleEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoginWithGoogleEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$LoginWithGoogleEventImpl>
    implements _$$LoginWithGoogleEventImplCopyWith<$Res> {
  __$$LoginWithGoogleEventImplCopyWithImpl(_$LoginWithGoogleEventImpl _value,
      $Res Function(_$LoginWithGoogleEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoginWithGoogleEventImpl implements LoginWithGoogleEvent {
  const _$LoginWithGoogleEventImpl();

  @override
  String toString() {
    return 'AuthEvent.loginWithGoogle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginWithGoogleEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contact, String otp) verifyAndLogin,
    required TResult Function() loginWithGoogle,
    required TResult Function() checkSession,
    required TResult Function() logout,
    required TResult Function() deleteAccount,
    required TResult Function(String email, String password) loginEmployee,
  }) {
    return loginWithGoogle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contact, String otp)? verifyAndLogin,
    TResult? Function()? loginWithGoogle,
    TResult? Function()? checkSession,
    TResult? Function()? logout,
    TResult? Function()? deleteAccount,
    TResult? Function(String email, String password)? loginEmployee,
  }) {
    return loginWithGoogle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contact, String otp)? verifyAndLogin,
    TResult Function()? loginWithGoogle,
    TResult Function()? checkSession,
    TResult Function()? logout,
    TResult Function()? deleteAccount,
    TResult Function(String email, String password)? loginEmployee,
    required TResult orElse(),
  }) {
    if (loginWithGoogle != null) {
      return loginWithGoogle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VerifyAndLogin value) verifyAndLogin,
    required TResult Function(LoginWithGoogleEvent value) loginWithGoogle,
    required TResult Function(CheckSessionEvent value) checkSession,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(DeleteAccountEvent value) deleteAccount,
    required TResult Function(LoginEmployee value) loginEmployee,
  }) {
    return loginWithGoogle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VerifyAndLogin value)? verifyAndLogin,
    TResult? Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult? Function(CheckSessionEvent value)? checkSession,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(DeleteAccountEvent value)? deleteAccount,
    TResult? Function(LoginEmployee value)? loginEmployee,
  }) {
    return loginWithGoogle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VerifyAndLogin value)? verifyAndLogin,
    TResult Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult Function(CheckSessionEvent value)? checkSession,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(DeleteAccountEvent value)? deleteAccount,
    TResult Function(LoginEmployee value)? loginEmployee,
    required TResult orElse(),
  }) {
    if (loginWithGoogle != null) {
      return loginWithGoogle(this);
    }
    return orElse();
  }
}

abstract class LoginWithGoogleEvent implements AuthEvent {
  const factory LoginWithGoogleEvent() = _$LoginWithGoogleEventImpl;
}

/// @nodoc
abstract class _$$CheckSessionEventImplCopyWith<$Res> {
  factory _$$CheckSessionEventImplCopyWith(_$CheckSessionEventImpl value,
          $Res Function(_$CheckSessionEventImpl) then) =
      __$$CheckSessionEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CheckSessionEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$CheckSessionEventImpl>
    implements _$$CheckSessionEventImplCopyWith<$Res> {
  __$$CheckSessionEventImplCopyWithImpl(_$CheckSessionEventImpl _value,
      $Res Function(_$CheckSessionEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CheckSessionEventImpl implements CheckSessionEvent {
  const _$CheckSessionEventImpl();

  @override
  String toString() {
    return 'AuthEvent.checkSession()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CheckSessionEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contact, String otp) verifyAndLogin,
    required TResult Function() loginWithGoogle,
    required TResult Function() checkSession,
    required TResult Function() logout,
    required TResult Function() deleteAccount,
    required TResult Function(String email, String password) loginEmployee,
  }) {
    return checkSession();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contact, String otp)? verifyAndLogin,
    TResult? Function()? loginWithGoogle,
    TResult? Function()? checkSession,
    TResult? Function()? logout,
    TResult? Function()? deleteAccount,
    TResult? Function(String email, String password)? loginEmployee,
  }) {
    return checkSession?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contact, String otp)? verifyAndLogin,
    TResult Function()? loginWithGoogle,
    TResult Function()? checkSession,
    TResult Function()? logout,
    TResult Function()? deleteAccount,
    TResult Function(String email, String password)? loginEmployee,
    required TResult orElse(),
  }) {
    if (checkSession != null) {
      return checkSession();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VerifyAndLogin value) verifyAndLogin,
    required TResult Function(LoginWithGoogleEvent value) loginWithGoogle,
    required TResult Function(CheckSessionEvent value) checkSession,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(DeleteAccountEvent value) deleteAccount,
    required TResult Function(LoginEmployee value) loginEmployee,
  }) {
    return checkSession(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VerifyAndLogin value)? verifyAndLogin,
    TResult? Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult? Function(CheckSessionEvent value)? checkSession,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(DeleteAccountEvent value)? deleteAccount,
    TResult? Function(LoginEmployee value)? loginEmployee,
  }) {
    return checkSession?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VerifyAndLogin value)? verifyAndLogin,
    TResult Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult Function(CheckSessionEvent value)? checkSession,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(DeleteAccountEvent value)? deleteAccount,
    TResult Function(LoginEmployee value)? loginEmployee,
    required TResult orElse(),
  }) {
    if (checkSession != null) {
      return checkSession(this);
    }
    return orElse();
  }
}

abstract class CheckSessionEvent implements AuthEvent {
  const factory CheckSessionEvent() = _$CheckSessionEventImpl;
}

/// @nodoc
abstract class _$$LogoutEventImplCopyWith<$Res> {
  factory _$$LogoutEventImplCopyWith(
          _$LogoutEventImpl value, $Res Function(_$LogoutEventImpl) then) =
      __$$LogoutEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LogoutEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$LogoutEventImpl>
    implements _$$LogoutEventImplCopyWith<$Res> {
  __$$LogoutEventImplCopyWithImpl(
      _$LogoutEventImpl _value, $Res Function(_$LogoutEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LogoutEventImpl implements LogoutEvent {
  const _$LogoutEventImpl();

  @override
  String toString() {
    return 'AuthEvent.logout()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LogoutEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contact, String otp) verifyAndLogin,
    required TResult Function() loginWithGoogle,
    required TResult Function() checkSession,
    required TResult Function() logout,
    required TResult Function() deleteAccount,
    required TResult Function(String email, String password) loginEmployee,
  }) {
    return logout();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contact, String otp)? verifyAndLogin,
    TResult? Function()? loginWithGoogle,
    TResult? Function()? checkSession,
    TResult? Function()? logout,
    TResult? Function()? deleteAccount,
    TResult? Function(String email, String password)? loginEmployee,
  }) {
    return logout?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contact, String otp)? verifyAndLogin,
    TResult Function()? loginWithGoogle,
    TResult Function()? checkSession,
    TResult Function()? logout,
    TResult Function()? deleteAccount,
    TResult Function(String email, String password)? loginEmployee,
    required TResult orElse(),
  }) {
    if (logout != null) {
      return logout();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VerifyAndLogin value) verifyAndLogin,
    required TResult Function(LoginWithGoogleEvent value) loginWithGoogle,
    required TResult Function(CheckSessionEvent value) checkSession,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(DeleteAccountEvent value) deleteAccount,
    required TResult Function(LoginEmployee value) loginEmployee,
  }) {
    return logout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VerifyAndLogin value)? verifyAndLogin,
    TResult? Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult? Function(CheckSessionEvent value)? checkSession,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(DeleteAccountEvent value)? deleteAccount,
    TResult? Function(LoginEmployee value)? loginEmployee,
  }) {
    return logout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VerifyAndLogin value)? verifyAndLogin,
    TResult Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult Function(CheckSessionEvent value)? checkSession,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(DeleteAccountEvent value)? deleteAccount,
    TResult Function(LoginEmployee value)? loginEmployee,
    required TResult orElse(),
  }) {
    if (logout != null) {
      return logout(this);
    }
    return orElse();
  }
}

abstract class LogoutEvent implements AuthEvent {
  const factory LogoutEvent() = _$LogoutEventImpl;
}

/// @nodoc
abstract class _$$DeleteAccountEventImplCopyWith<$Res> {
  factory _$$DeleteAccountEventImplCopyWith(_$DeleteAccountEventImpl value,
          $Res Function(_$DeleteAccountEventImpl) then) =
      __$$DeleteAccountEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DeleteAccountEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$DeleteAccountEventImpl>
    implements _$$DeleteAccountEventImplCopyWith<$Res> {
  __$$DeleteAccountEventImplCopyWithImpl(_$DeleteAccountEventImpl _value,
      $Res Function(_$DeleteAccountEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DeleteAccountEventImpl implements DeleteAccountEvent {
  const _$DeleteAccountEventImpl();

  @override
  String toString() {
    return 'AuthEvent.deleteAccount()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DeleteAccountEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contact, String otp) verifyAndLogin,
    required TResult Function() loginWithGoogle,
    required TResult Function() checkSession,
    required TResult Function() logout,
    required TResult Function() deleteAccount,
    required TResult Function(String email, String password) loginEmployee,
  }) {
    return deleteAccount();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contact, String otp)? verifyAndLogin,
    TResult? Function()? loginWithGoogle,
    TResult? Function()? checkSession,
    TResult? Function()? logout,
    TResult? Function()? deleteAccount,
    TResult? Function(String email, String password)? loginEmployee,
  }) {
    return deleteAccount?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contact, String otp)? verifyAndLogin,
    TResult Function()? loginWithGoogle,
    TResult Function()? checkSession,
    TResult Function()? logout,
    TResult Function()? deleteAccount,
    TResult Function(String email, String password)? loginEmployee,
    required TResult orElse(),
  }) {
    if (deleteAccount != null) {
      return deleteAccount();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VerifyAndLogin value) verifyAndLogin,
    required TResult Function(LoginWithGoogleEvent value) loginWithGoogle,
    required TResult Function(CheckSessionEvent value) checkSession,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(DeleteAccountEvent value) deleteAccount,
    required TResult Function(LoginEmployee value) loginEmployee,
  }) {
    return deleteAccount(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VerifyAndLogin value)? verifyAndLogin,
    TResult? Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult? Function(CheckSessionEvent value)? checkSession,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(DeleteAccountEvent value)? deleteAccount,
    TResult? Function(LoginEmployee value)? loginEmployee,
  }) {
    return deleteAccount?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VerifyAndLogin value)? verifyAndLogin,
    TResult Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult Function(CheckSessionEvent value)? checkSession,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(DeleteAccountEvent value)? deleteAccount,
    TResult Function(LoginEmployee value)? loginEmployee,
    required TResult orElse(),
  }) {
    if (deleteAccount != null) {
      return deleteAccount(this);
    }
    return orElse();
  }
}

abstract class DeleteAccountEvent implements AuthEvent {
  const factory DeleteAccountEvent() = _$DeleteAccountEventImpl;
}

/// @nodoc
abstract class _$$LoginEmployeeImplCopyWith<$Res> {
  factory _$$LoginEmployeeImplCopyWith(
          _$LoginEmployeeImpl value, $Res Function(_$LoginEmployeeImpl) then) =
      __$$LoginEmployeeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$LoginEmployeeImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$LoginEmployeeImpl>
    implements _$$LoginEmployeeImplCopyWith<$Res> {
  __$$LoginEmployeeImplCopyWithImpl(
      _$LoginEmployeeImpl _value, $Res Function(_$LoginEmployeeImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_$LoginEmployeeImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LoginEmployeeImpl implements LoginEmployee {
  const _$LoginEmployeeImpl({required this.email, required this.password});

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'AuthEvent.loginEmployee(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginEmployeeImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginEmployeeImplCopyWith<_$LoginEmployeeImpl> get copyWith =>
      __$$LoginEmployeeImplCopyWithImpl<_$LoginEmployeeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contact, String otp) verifyAndLogin,
    required TResult Function() loginWithGoogle,
    required TResult Function() checkSession,
    required TResult Function() logout,
    required TResult Function() deleteAccount,
    required TResult Function(String email, String password) loginEmployee,
  }) {
    return loginEmployee(email, password);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contact, String otp)? verifyAndLogin,
    TResult? Function()? loginWithGoogle,
    TResult? Function()? checkSession,
    TResult? Function()? logout,
    TResult? Function()? deleteAccount,
    TResult? Function(String email, String password)? loginEmployee,
  }) {
    return loginEmployee?.call(email, password);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contact, String otp)? verifyAndLogin,
    TResult Function()? loginWithGoogle,
    TResult Function()? checkSession,
    TResult Function()? logout,
    TResult Function()? deleteAccount,
    TResult Function(String email, String password)? loginEmployee,
    required TResult orElse(),
  }) {
    if (loginEmployee != null) {
      return loginEmployee(email, password);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VerifyAndLogin value) verifyAndLogin,
    required TResult Function(LoginWithGoogleEvent value) loginWithGoogle,
    required TResult Function(CheckSessionEvent value) checkSession,
    required TResult Function(LogoutEvent value) logout,
    required TResult Function(DeleteAccountEvent value) deleteAccount,
    required TResult Function(LoginEmployee value) loginEmployee,
  }) {
    return loginEmployee(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VerifyAndLogin value)? verifyAndLogin,
    TResult? Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult? Function(CheckSessionEvent value)? checkSession,
    TResult? Function(LogoutEvent value)? logout,
    TResult? Function(DeleteAccountEvent value)? deleteAccount,
    TResult? Function(LoginEmployee value)? loginEmployee,
  }) {
    return loginEmployee?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VerifyAndLogin value)? verifyAndLogin,
    TResult Function(LoginWithGoogleEvent value)? loginWithGoogle,
    TResult Function(CheckSessionEvent value)? checkSession,
    TResult Function(LogoutEvent value)? logout,
    TResult Function(DeleteAccountEvent value)? deleteAccount,
    TResult Function(LoginEmployee value)? loginEmployee,
    required TResult orElse(),
  }) {
    if (loginEmployee != null) {
      return loginEmployee(this);
    }
    return orElse();
  }
}

abstract class LoginEmployee implements AuthEvent {
  const factory LoginEmployee(
      {required final String email,
      required final String password}) = _$LoginEmployeeImpl;

  String get email;
  String get password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginEmployeeImplCopyWith<_$LoginEmployeeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
