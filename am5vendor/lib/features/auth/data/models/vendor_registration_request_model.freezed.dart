// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_registration_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceCategorySelection _$ServiceCategorySelectionFromJson(
    Map<String, dynamic> json) {
  return _ServiceCategorySelection.fromJson(json);
}

/// @nodoc
mixin _$ServiceCategorySelection {
  @JsonKey(name: 'main_category_id')
  int get mainCategoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sub_category_ids')
  List<int> get subCategoryIds => throw _privateConstructorUsedError;

  /// Serializes this ServiceCategorySelection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceCategorySelection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceCategorySelectionCopyWith<ServiceCategorySelection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceCategorySelectionCopyWith<$Res> {
  factory $ServiceCategorySelectionCopyWith(ServiceCategorySelection value,
          $Res Function(ServiceCategorySelection) then) =
      _$ServiceCategorySelectionCopyWithImpl<$Res, ServiceCategorySelection>;
  @useResult
  $Res call(
      {@JsonKey(name: 'main_category_id') int mainCategoryId,
      @JsonKey(name: 'sub_category_ids') List<int> subCategoryIds});
}

/// @nodoc
class _$ServiceCategorySelectionCopyWithImpl<$Res,
        $Val extends ServiceCategorySelection>
    implements $ServiceCategorySelectionCopyWith<$Res> {
  _$ServiceCategorySelectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceCategorySelection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mainCategoryId = null,
    Object? subCategoryIds = null,
  }) {
    return _then(_value.copyWith(
      mainCategoryId: null == mainCategoryId
          ? _value.mainCategoryId
          : mainCategoryId // ignore: cast_nullable_to_non_nullable
              as int,
      subCategoryIds: null == subCategoryIds
          ? _value.subCategoryIds
          : subCategoryIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServiceCategorySelectionImplCopyWith<$Res>
    implements $ServiceCategorySelectionCopyWith<$Res> {
  factory _$$ServiceCategorySelectionImplCopyWith(
          _$ServiceCategorySelectionImpl value,
          $Res Function(_$ServiceCategorySelectionImpl) then) =
      __$$ServiceCategorySelectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'main_category_id') int mainCategoryId,
      @JsonKey(name: 'sub_category_ids') List<int> subCategoryIds});
}

/// @nodoc
class __$$ServiceCategorySelectionImplCopyWithImpl<$Res>
    extends _$ServiceCategorySelectionCopyWithImpl<$Res,
        _$ServiceCategorySelectionImpl>
    implements _$$ServiceCategorySelectionImplCopyWith<$Res> {
  __$$ServiceCategorySelectionImplCopyWithImpl(
      _$ServiceCategorySelectionImpl _value,
      $Res Function(_$ServiceCategorySelectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceCategorySelection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mainCategoryId = null,
    Object? subCategoryIds = null,
  }) {
    return _then(_$ServiceCategorySelectionImpl(
      mainCategoryId: null == mainCategoryId
          ? _value.mainCategoryId
          : mainCategoryId // ignore: cast_nullable_to_non_nullable
              as int,
      subCategoryIds: null == subCategoryIds
          ? _value._subCategoryIds
          : subCategoryIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceCategorySelectionImpl implements _ServiceCategorySelection {
  const _$ServiceCategorySelectionImpl(
      {@JsonKey(name: 'main_category_id') required this.mainCategoryId,
      @JsonKey(name: 'sub_category_ids')
      required final List<int> subCategoryIds})
      : _subCategoryIds = subCategoryIds;

  factory _$ServiceCategorySelectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceCategorySelectionImplFromJson(json);

  @override
  @JsonKey(name: 'main_category_id')
  final int mainCategoryId;
  final List<int> _subCategoryIds;
  @override
  @JsonKey(name: 'sub_category_ids')
  List<int> get subCategoryIds {
    if (_subCategoryIds is EqualUnmodifiableListView) return _subCategoryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subCategoryIds);
  }

  @override
  String toString() {
    return 'ServiceCategorySelection(mainCategoryId: $mainCategoryId, subCategoryIds: $subCategoryIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceCategorySelectionImpl &&
            (identical(other.mainCategoryId, mainCategoryId) ||
                other.mainCategoryId == mainCategoryId) &&
            const DeepCollectionEquality()
                .equals(other._subCategoryIds, _subCategoryIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mainCategoryId,
      const DeepCollectionEquality().hash(_subCategoryIds));

  /// Create a copy of ServiceCategorySelection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceCategorySelectionImplCopyWith<_$ServiceCategorySelectionImpl>
      get copyWith => __$$ServiceCategorySelectionImplCopyWithImpl<
          _$ServiceCategorySelectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceCategorySelectionImplToJson(
      this,
    );
  }
}

abstract class _ServiceCategorySelection implements ServiceCategorySelection {
  const factory _ServiceCategorySelection(
          {@JsonKey(name: 'main_category_id') required final int mainCategoryId,
          @JsonKey(name: 'sub_category_ids')
          required final List<int> subCategoryIds}) =
      _$ServiceCategorySelectionImpl;

  factory _ServiceCategorySelection.fromJson(Map<String, dynamic> json) =
      _$ServiceCategorySelectionImpl.fromJson;

  @override
  @JsonKey(name: 'main_category_id')
  int get mainCategoryId;
  @override
  @JsonKey(name: 'sub_category_ids')
  List<int> get subCategoryIds;

  /// Create a copy of ServiceCategorySelection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceCategorySelectionImplCopyWith<_$ServiceCategorySelectionImpl>
      get copyWith => throw _privateConstructorUsedError;
}

VendorRegistrationRequestModel _$VendorRegistrationRequestModelFromJson(
    Map<String, dynamic> json) {
  return _VendorRegistrationRequestModel.fromJson(json);
}

/// @nodoc
mixin _$VendorRegistrationRequestModel {
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'father_name')
  String? get fatherName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile')
  String? get mobile => throw _privateConstructorUsedError;
  @JsonKey(name: 'alternative_number')
  String? get altMobile => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_name')
  String get businessName => throw _privateConstructorUsedError;
  @JsonKey(name: 'aadhaar_number')
  String get aadhaarNumber => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get street => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get pincode => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_radius_km')
  int? get serviceRadiusKm => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_image')
  String? get profileImage => throw _privateConstructorUsedError;
  List<ServiceCategorySelection> get categories =>
      throw _privateConstructorUsedError;

  /// Serializes this VendorRegistrationRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VendorRegistrationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorRegistrationRequestModelCopyWith<VendorRegistrationRequestModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorRegistrationRequestModelCopyWith<$Res> {
  factory $VendorRegistrationRequestModelCopyWith(
          VendorRegistrationRequestModel value,
          $Res Function(VendorRegistrationRequestModel) then) =
      _$VendorRegistrationRequestModelCopyWithImpl<$Res,
          VendorRegistrationRequestModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String? lastName,
      @JsonKey(name: 'father_name') String? fatherName,
      String? email,
      @JsonKey(name: 'mobile') String? mobile,
      @JsonKey(name: 'alternative_number') String? altMobile,
      @JsonKey(name: 'business_name') String businessName,
      @JsonKey(name: 'aadhaar_number') String aadhaarNumber,
      String address,
      String? street,
      String city,
      String? district,
      String state,
      String pincode,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'service_radius_km') int? serviceRadiusKm,
      @JsonKey(name: 'profile_image') String? profileImage,
      List<ServiceCategorySelection> categories});
}

/// @nodoc
class _$VendorRegistrationRequestModelCopyWithImpl<$Res,
        $Val extends VendorRegistrationRequestModel>
    implements $VendorRegistrationRequestModelCopyWith<$Res> {
  _$VendorRegistrationRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorRegistrationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = freezed,
    Object? fatherName = freezed,
    Object? email = freezed,
    Object? mobile = freezed,
    Object? altMobile = freezed,
    Object? businessName = null,
    Object? aadhaarNumber = null,
    Object? address = null,
    Object? street = freezed,
    Object? city = null,
    Object? district = freezed,
    Object? state = null,
    Object? pincode = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? serviceRadiusKm = freezed,
    Object? profileImage = freezed,
    Object? categories = null,
  }) {
    return _then(_value.copyWith(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      fatherName: freezed == fatherName
          ? _value.fatherName
          : fatherName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      mobile: freezed == mobile
          ? _value.mobile
          : mobile // ignore: cast_nullable_to_non_nullable
              as String?,
      altMobile: freezed == altMobile
          ? _value.altMobile
          : altMobile // ignore: cast_nullable_to_non_nullable
              as String?,
      businessName: null == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String,
      aadhaarNumber: null == aadhaarNumber
          ? _value.aadhaarNumber
          : aadhaarNumber // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      street: freezed == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String?,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      pincode: null == pincode
          ? _value.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      serviceRadiusKm: freezed == serviceRadiusKm
          ? _value.serviceRadiusKm
          : serviceRadiusKm // ignore: cast_nullable_to_non_nullable
              as int?,
      profileImage: freezed == profileImage
          ? _value.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<ServiceCategorySelection>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VendorRegistrationRequestModelImplCopyWith<$Res>
    implements $VendorRegistrationRequestModelCopyWith<$Res> {
  factory _$$VendorRegistrationRequestModelImplCopyWith(
          _$VendorRegistrationRequestModelImpl value,
          $Res Function(_$VendorRegistrationRequestModelImpl) then) =
      __$$VendorRegistrationRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String? lastName,
      @JsonKey(name: 'father_name') String? fatherName,
      String? email,
      @JsonKey(name: 'mobile') String? mobile,
      @JsonKey(name: 'alternative_number') String? altMobile,
      @JsonKey(name: 'business_name') String businessName,
      @JsonKey(name: 'aadhaar_number') String aadhaarNumber,
      String address,
      String? street,
      String city,
      String? district,
      String state,
      String pincode,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'service_radius_km') int? serviceRadiusKm,
      @JsonKey(name: 'profile_image') String? profileImage,
      List<ServiceCategorySelection> categories});
}

/// @nodoc
class __$$VendorRegistrationRequestModelImplCopyWithImpl<$Res>
    extends _$VendorRegistrationRequestModelCopyWithImpl<$Res,
        _$VendorRegistrationRequestModelImpl>
    implements _$$VendorRegistrationRequestModelImplCopyWith<$Res> {
  __$$VendorRegistrationRequestModelImplCopyWithImpl(
      _$VendorRegistrationRequestModelImpl _value,
      $Res Function(_$VendorRegistrationRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VendorRegistrationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = freezed,
    Object? fatherName = freezed,
    Object? email = freezed,
    Object? mobile = freezed,
    Object? altMobile = freezed,
    Object? businessName = null,
    Object? aadhaarNumber = null,
    Object? address = null,
    Object? street = freezed,
    Object? city = null,
    Object? district = freezed,
    Object? state = null,
    Object? pincode = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? serviceRadiusKm = freezed,
    Object? profileImage = freezed,
    Object? categories = null,
  }) {
    return _then(_$VendorRegistrationRequestModelImpl(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      fatherName: freezed == fatherName
          ? _value.fatherName
          : fatherName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      mobile: freezed == mobile
          ? _value.mobile
          : mobile // ignore: cast_nullable_to_non_nullable
              as String?,
      altMobile: freezed == altMobile
          ? _value.altMobile
          : altMobile // ignore: cast_nullable_to_non_nullable
              as String?,
      businessName: null == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String,
      aadhaarNumber: null == aadhaarNumber
          ? _value.aadhaarNumber
          : aadhaarNumber // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      street: freezed == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String?,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      pincode: null == pincode
          ? _value.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      serviceRadiusKm: freezed == serviceRadiusKm
          ? _value.serviceRadiusKm
          : serviceRadiusKm // ignore: cast_nullable_to_non_nullable
              as int?,
      profileImage: freezed == profileImage
          ? _value.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<ServiceCategorySelection>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorRegistrationRequestModelImpl
    implements _VendorRegistrationRequestModel {
  const _$VendorRegistrationRequestModelImpl(
      {@JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') this.lastName,
      @JsonKey(name: 'father_name') this.fatherName,
      this.email,
      @JsonKey(name: 'mobile') this.mobile,
      @JsonKey(name: 'alternative_number') this.altMobile,
      @JsonKey(name: 'business_name') required this.businessName,
      @JsonKey(name: 'aadhaar_number') required this.aadhaarNumber,
      required this.address,
      this.street,
      required this.city,
      this.district,
      required this.state,
      required this.pincode,
      required this.latitude,
      required this.longitude,
      @JsonKey(name: 'service_radius_km') this.serviceRadiusKm = 10,
      @JsonKey(name: 'profile_image') this.profileImage,
      required final List<ServiceCategorySelection> categories})
      : _categories = categories;

  factory _$VendorRegistrationRequestModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$VendorRegistrationRequestModelImplFromJson(json);

  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  @JsonKey(name: 'father_name')
  final String? fatherName;
  @override
  final String? email;
  @override
  @JsonKey(name: 'mobile')
  final String? mobile;
  @override
  @JsonKey(name: 'alternative_number')
  final String? altMobile;
  @override
  @JsonKey(name: 'business_name')
  final String businessName;
  @override
  @JsonKey(name: 'aadhaar_number')
  final String aadhaarNumber;
  @override
  final String address;
  @override
  final String? street;
  @override
  final String city;
  @override
  final String? district;
  @override
  final String state;
  @override
  final String pincode;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'service_radius_km')
  final int? serviceRadiusKm;
  @override
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  final List<ServiceCategorySelection> _categories;
  @override
  List<ServiceCategorySelection> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  String toString() {
    return 'VendorRegistrationRequestModel(firstName: $firstName, lastName: $lastName, fatherName: $fatherName, email: $email, mobile: $mobile, altMobile: $altMobile, businessName: $businessName, aadhaarNumber: $aadhaarNumber, address: $address, street: $street, city: $city, district: $district, state: $state, pincode: $pincode, latitude: $latitude, longitude: $longitude, serviceRadiusKm: $serviceRadiusKm, profileImage: $profileImage, categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorRegistrationRequestModelImpl &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.fatherName, fatherName) ||
                other.fatherName == fatherName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.mobile, mobile) || other.mobile == mobile) &&
            (identical(other.altMobile, altMobile) ||
                other.altMobile == altMobile) &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.aadhaarNumber, aadhaarNumber) ||
                other.aadhaarNumber == aadhaarNumber) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pincode, pincode) || other.pincode == pincode) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.serviceRadiusKm, serviceRadiusKm) ||
                other.serviceRadiusKm == serviceRadiusKm) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        firstName,
        lastName,
        fatherName,
        email,
        mobile,
        altMobile,
        businessName,
        aadhaarNumber,
        address,
        street,
        city,
        district,
        state,
        pincode,
        latitude,
        longitude,
        serviceRadiusKm,
        profileImage,
        const DeepCollectionEquality().hash(_categories)
      ]);

  /// Create a copy of VendorRegistrationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorRegistrationRequestModelImplCopyWith<
          _$VendorRegistrationRequestModelImpl>
      get copyWith => __$$VendorRegistrationRequestModelImplCopyWithImpl<
          _$VendorRegistrationRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorRegistrationRequestModelImplToJson(
      this,
    );
  }
}

abstract class _VendorRegistrationRequestModel
    implements VendorRegistrationRequestModel {
  const factory _VendorRegistrationRequestModel(
          {@JsonKey(name: 'first_name') required final String firstName,
          @JsonKey(name: 'last_name') final String? lastName,
          @JsonKey(name: 'father_name') final String? fatherName,
          final String? email,
          @JsonKey(name: 'mobile') final String? mobile,
          @JsonKey(name: 'alternative_number') final String? altMobile,
          @JsonKey(name: 'business_name') required final String businessName,
          @JsonKey(name: 'aadhaar_number') required final String aadhaarNumber,
          required final String address,
          final String? street,
          required final String city,
          final String? district,
          required final String state,
          required final String pincode,
          required final double? latitude,
          required final double? longitude,
          @JsonKey(name: 'service_radius_km') final int? serviceRadiusKm,
          @JsonKey(name: 'profile_image') final String? profileImage,
          required final List<ServiceCategorySelection> categories}) =
      _$VendorRegistrationRequestModelImpl;

  factory _VendorRegistrationRequestModel.fromJson(Map<String, dynamic> json) =
      _$VendorRegistrationRequestModelImpl.fromJson;

  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  @JsonKey(name: 'father_name')
  String? get fatherName;
  @override
  String? get email;
  @override
  @JsonKey(name: 'mobile')
  String? get mobile;
  @override
  @JsonKey(name: 'alternative_number')
  String? get altMobile;
  @override
  @JsonKey(name: 'business_name')
  String get businessName;
  @override
  @JsonKey(name: 'aadhaar_number')
  String get aadhaarNumber;
  @override
  String get address;
  @override
  String? get street;
  @override
  String get city;
  @override
  String? get district;
  @override
  String get state;
  @override
  String get pincode;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  @JsonKey(name: 'service_radius_km')
  int? get serviceRadiusKm;
  @override
  @JsonKey(name: 'profile_image')
  String? get profileImage;
  @override
  List<ServiceCategorySelection> get categories;

  /// Create a copy of VendorRegistrationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorRegistrationRequestModelImplCopyWith<
          _$VendorRegistrationRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
