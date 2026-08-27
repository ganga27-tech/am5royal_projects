// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_vendor_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RegisterVendorEvent {
  VendorRegistrationRequestModel get request =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VendorRegistrationRequestModel request) submit,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VendorRegistrationRequestModel request)? submit,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VendorRegistrationRequestModel request)? submit,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SubmitVendorRegistration value) submit,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubmitVendorRegistration value)? submit,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubmitVendorRegistration value)? submit,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of RegisterVendorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterVendorEventCopyWith<RegisterVendorEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterVendorEventCopyWith<$Res> {
  factory $RegisterVendorEventCopyWith(
          RegisterVendorEvent value, $Res Function(RegisterVendorEvent) then) =
      _$RegisterVendorEventCopyWithImpl<$Res, RegisterVendorEvent>;
  @useResult
  $Res call({VendorRegistrationRequestModel request});

  $VendorRegistrationRequestModelCopyWith<$Res> get request;
}

/// @nodoc
class _$RegisterVendorEventCopyWithImpl<$Res, $Val extends RegisterVendorEvent>
    implements $RegisterVendorEventCopyWith<$Res> {
  _$RegisterVendorEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterVendorEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? request = null,
  }) {
    return _then(_value.copyWith(
      request: null == request
          ? _value.request
          : request // ignore: cast_nullable_to_non_nullable
              as VendorRegistrationRequestModel,
    ) as $Val);
  }

  /// Create a copy of RegisterVendorEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VendorRegistrationRequestModelCopyWith<$Res> get request {
    return $VendorRegistrationRequestModelCopyWith<$Res>(_value.request,
        (value) {
      return _then(_value.copyWith(request: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubmitVendorRegistrationImplCopyWith<$Res>
    implements $RegisterVendorEventCopyWith<$Res> {
  factory _$$SubmitVendorRegistrationImplCopyWith(
          _$SubmitVendorRegistrationImpl value,
          $Res Function(_$SubmitVendorRegistrationImpl) then) =
      __$$SubmitVendorRegistrationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VendorRegistrationRequestModel request});

  @override
  $VendorRegistrationRequestModelCopyWith<$Res> get request;
}

/// @nodoc
class __$$SubmitVendorRegistrationImplCopyWithImpl<$Res>
    extends _$RegisterVendorEventCopyWithImpl<$Res,
        _$SubmitVendorRegistrationImpl>
    implements _$$SubmitVendorRegistrationImplCopyWith<$Res> {
  __$$SubmitVendorRegistrationImplCopyWithImpl(
      _$SubmitVendorRegistrationImpl _value,
      $Res Function(_$SubmitVendorRegistrationImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterVendorEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? request = null,
  }) {
    return _then(_$SubmitVendorRegistrationImpl(
      null == request
          ? _value.request
          : request // ignore: cast_nullable_to_non_nullable
              as VendorRegistrationRequestModel,
    ));
  }
}

/// @nodoc

class _$SubmitVendorRegistrationImpl implements SubmitVendorRegistration {
  const _$SubmitVendorRegistrationImpl(this.request);

  @override
  final VendorRegistrationRequestModel request;

  @override
  String toString() {
    return 'RegisterVendorEvent.submit(request: $request)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitVendorRegistrationImpl &&
            (identical(other.request, request) || other.request == request));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request);

  /// Create a copy of RegisterVendorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitVendorRegistrationImplCopyWith<_$SubmitVendorRegistrationImpl>
      get copyWith => __$$SubmitVendorRegistrationImplCopyWithImpl<
          _$SubmitVendorRegistrationImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VendorRegistrationRequestModel request) submit,
  }) {
    return submit(request);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VendorRegistrationRequestModel request)? submit,
  }) {
    return submit?.call(request);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VendorRegistrationRequestModel request)? submit,
    required TResult orElse(),
  }) {
    if (submit != null) {
      return submit(request);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SubmitVendorRegistration value) submit,
  }) {
    return submit(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubmitVendorRegistration value)? submit,
  }) {
    return submit?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubmitVendorRegistration value)? submit,
    required TResult orElse(),
  }) {
    if (submit != null) {
      return submit(this);
    }
    return orElse();
  }
}

abstract class SubmitVendorRegistration implements RegisterVendorEvent {
  const factory SubmitVendorRegistration(
          final VendorRegistrationRequestModel request) =
      _$SubmitVendorRegistrationImpl;

  @override
  VendorRegistrationRequestModel get request;

  /// Create a copy of RegisterVendorEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmitVendorRegistrationImplCopyWith<_$SubmitVendorRegistrationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
