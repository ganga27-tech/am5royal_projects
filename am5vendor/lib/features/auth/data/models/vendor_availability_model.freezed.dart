// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_availability_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VendorAvailabilityModel _$VendorAvailabilityModelFromJson(
    Map<String, dynamic> json) {
  return _VendorAvailabilityModel.fromJson(json);
}

/// @nodoc
mixin _$VendorAvailabilityModel {
  @JsonKey(name: 'day_of_week')
  int get dayOfWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  String get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  String get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_available')
  bool get isAvailable => throw _privateConstructorUsedError;

  /// Serializes this VendorAvailabilityModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VendorAvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorAvailabilityModelCopyWith<VendorAvailabilityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorAvailabilityModelCopyWith<$Res> {
  factory $VendorAvailabilityModelCopyWith(VendorAvailabilityModel value,
          $Res Function(VendorAvailabilityModel) then) =
      _$VendorAvailabilityModelCopyWithImpl<$Res, VendorAvailabilityModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'day_of_week') int dayOfWeek,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime,
      @JsonKey(name: 'is_available') bool isAvailable});
}

/// @nodoc
class _$VendorAvailabilityModelCopyWithImpl<$Res,
        $Val extends VendorAvailabilityModel>
    implements $VendorAvailabilityModelCopyWith<$Res> {
  _$VendorAvailabilityModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorAvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isAvailable = null,
  }) {
    return _then(_value.copyWith(
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VendorAvailabilityModelImplCopyWith<$Res>
    implements $VendorAvailabilityModelCopyWith<$Res> {
  factory _$$VendorAvailabilityModelImplCopyWith(
          _$VendorAvailabilityModelImpl value,
          $Res Function(_$VendorAvailabilityModelImpl) then) =
      __$$VendorAvailabilityModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'day_of_week') int dayOfWeek,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime,
      @JsonKey(name: 'is_available') bool isAvailable});
}

/// @nodoc
class __$$VendorAvailabilityModelImplCopyWithImpl<$Res>
    extends _$VendorAvailabilityModelCopyWithImpl<$Res,
        _$VendorAvailabilityModelImpl>
    implements _$$VendorAvailabilityModelImplCopyWith<$Res> {
  __$$VendorAvailabilityModelImplCopyWithImpl(
      _$VendorAvailabilityModelImpl _value,
      $Res Function(_$VendorAvailabilityModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VendorAvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isAvailable = null,
  }) {
    return _then(_$VendorAvailabilityModelImpl(
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorAvailabilityModelImpl implements _VendorAvailabilityModel {
  const _$VendorAvailabilityModelImpl(
      {@JsonKey(name: 'day_of_week') required this.dayOfWeek,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') required this.endTime,
      @JsonKey(name: 'is_available') required this.isAvailable});

  factory _$VendorAvailabilityModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorAvailabilityModelImplFromJson(json);

  @override
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;
  @override
  @JsonKey(name: 'start_time')
  final String startTime;
  @override
  @JsonKey(name: 'end_time')
  final String endTime;
  @override
  @JsonKey(name: 'is_available')
  final bool isAvailable;

  @override
  String toString() {
    return 'VendorAvailabilityModel(dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorAvailabilityModelImpl &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, dayOfWeek, startTime, endTime, isAvailable);

  /// Create a copy of VendorAvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorAvailabilityModelImplCopyWith<_$VendorAvailabilityModelImpl>
      get copyWith => __$$VendorAvailabilityModelImplCopyWithImpl<
          _$VendorAvailabilityModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorAvailabilityModelImplToJson(
      this,
    );
  }
}

abstract class _VendorAvailabilityModel implements VendorAvailabilityModel {
  const factory _VendorAvailabilityModel(
          {@JsonKey(name: 'day_of_week') required final int dayOfWeek,
          @JsonKey(name: 'start_time') required final String startTime,
          @JsonKey(name: 'end_time') required final String endTime,
          @JsonKey(name: 'is_available') required final bool isAvailable}) =
      _$VendorAvailabilityModelImpl;

  factory _VendorAvailabilityModel.fromJson(Map<String, dynamic> json) =
      _$VendorAvailabilityModelImpl.fromJson;

  @override
  @JsonKey(name: 'day_of_week')
  int get dayOfWeek;
  @override
  @JsonKey(name: 'start_time')
  String get startTime;
  @override
  @JsonKey(name: 'end_time')
  String get endTime;
  @override
  @JsonKey(name: 'is_available')
  bool get isAvailable;

  /// Create a copy of VendorAvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorAvailabilityModelImplCopyWith<_$VendorAvailabilityModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
