// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProductEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? search) loadProducts,
    required TResult Function(String id) loadProductDetail,
    required TResult Function(String name, String description, double price,
            int stock, String imageUrl, String category)
        createProduct,
    required TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)
        updateProduct,
    required TResult Function(String id) deleteProduct,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? search)? loadProducts,
    TResult? Function(String id)? loadProductDetail,
    TResult? Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult? Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? search)? loadProducts,
    TResult Function(String id)? loadProductDetail,
    TResult Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult Function(String id)? deleteProduct,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProducts value) loadProducts,
    required TResult Function(LoadProductDetail value) loadProductDetail,
    required TResult Function(CreateProductEvent value) createProduct,
    required TResult Function(UpdateProductEvent value) updateProduct,
    required TResult Function(DeleteProductEvent value) deleteProduct,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProducts value)? loadProducts,
    TResult? Function(LoadProductDetail value)? loadProductDetail,
    TResult? Function(CreateProductEvent value)? createProduct,
    TResult? Function(UpdateProductEvent value)? updateProduct,
    TResult? Function(DeleteProductEvent value)? deleteProduct,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProducts value)? loadProducts,
    TResult Function(LoadProductDetail value)? loadProductDetail,
    TResult Function(CreateProductEvent value)? createProduct,
    TResult Function(UpdateProductEvent value)? updateProduct,
    TResult Function(DeleteProductEvent value)? deleteProduct,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductEventCopyWith<$Res> {
  factory $ProductEventCopyWith(
          ProductEvent value, $Res Function(ProductEvent) then) =
      _$ProductEventCopyWithImpl<$Res, ProductEvent>;
}

/// @nodoc
class _$ProductEventCopyWithImpl<$Res, $Val extends ProductEvent>
    implements $ProductEventCopyWith<$Res> {
  _$ProductEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadProductsImplCopyWith<$Res> {
  factory _$$LoadProductsImplCopyWith(
          _$LoadProductsImpl value, $Res Function(_$LoadProductsImpl) then) =
      __$$LoadProductsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? search});
}

/// @nodoc
class __$$LoadProductsImplCopyWithImpl<$Res>
    extends _$ProductEventCopyWithImpl<$Res, _$LoadProductsImpl>
    implements _$$LoadProductsImplCopyWith<$Res> {
  __$$LoadProductsImplCopyWithImpl(
      _$LoadProductsImpl _value, $Res Function(_$LoadProductsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = freezed,
  }) {
    return _then(_$LoadProductsImpl(
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LoadProductsImpl implements LoadProducts {
  const _$LoadProductsImpl({this.search});

  @override
  final String? search;

  @override
  String toString() {
    return 'ProductEvent.loadProducts(search: $search)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadProductsImpl &&
            (identical(other.search, search) || other.search == search));
  }

  @override
  int get hashCode => Object.hash(runtimeType, search);

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadProductsImplCopyWith<_$LoadProductsImpl> get copyWith =>
      __$$LoadProductsImplCopyWithImpl<_$LoadProductsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? search) loadProducts,
    required TResult Function(String id) loadProductDetail,
    required TResult Function(String name, String description, double price,
            int stock, String imageUrl, String category)
        createProduct,
    required TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)
        updateProduct,
    required TResult Function(String id) deleteProduct,
  }) {
    return loadProducts(search);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? search)? loadProducts,
    TResult? Function(String id)? loadProductDetail,
    TResult? Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult? Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) {
    return loadProducts?.call(search);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? search)? loadProducts,
    TResult Function(String id)? loadProductDetail,
    TResult Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult Function(String id)? deleteProduct,
    required TResult orElse(),
  }) {
    if (loadProducts != null) {
      return loadProducts(search);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProducts value) loadProducts,
    required TResult Function(LoadProductDetail value) loadProductDetail,
    required TResult Function(CreateProductEvent value) createProduct,
    required TResult Function(UpdateProductEvent value) updateProduct,
    required TResult Function(DeleteProductEvent value) deleteProduct,
  }) {
    return loadProducts(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProducts value)? loadProducts,
    TResult? Function(LoadProductDetail value)? loadProductDetail,
    TResult? Function(CreateProductEvent value)? createProduct,
    TResult? Function(UpdateProductEvent value)? updateProduct,
    TResult? Function(DeleteProductEvent value)? deleteProduct,
  }) {
    return loadProducts?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProducts value)? loadProducts,
    TResult Function(LoadProductDetail value)? loadProductDetail,
    TResult Function(CreateProductEvent value)? createProduct,
    TResult Function(UpdateProductEvent value)? updateProduct,
    TResult Function(DeleteProductEvent value)? deleteProduct,
    required TResult orElse(),
  }) {
    if (loadProducts != null) {
      return loadProducts(this);
    }
    return orElse();
  }
}

abstract class LoadProducts implements ProductEvent {
  const factory LoadProducts({final String? search}) = _$LoadProductsImpl;

  String? get search;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadProductsImplCopyWith<_$LoadProductsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadProductDetailImplCopyWith<$Res> {
  factory _$$LoadProductDetailImplCopyWith(_$LoadProductDetailImpl value,
          $Res Function(_$LoadProductDetailImpl) then) =
      __$$LoadProductDetailImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$LoadProductDetailImplCopyWithImpl<$Res>
    extends _$ProductEventCopyWithImpl<$Res, _$LoadProductDetailImpl>
    implements _$$LoadProductDetailImplCopyWith<$Res> {
  __$$LoadProductDetailImplCopyWithImpl(_$LoadProductDetailImpl _value,
      $Res Function(_$LoadProductDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$LoadProductDetailImpl(
      null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LoadProductDetailImpl implements LoadProductDetail {
  const _$LoadProductDetailImpl(this.id);

  @override
  final String id;

  @override
  String toString() {
    return 'ProductEvent.loadProductDetail(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadProductDetailImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadProductDetailImplCopyWith<_$LoadProductDetailImpl> get copyWith =>
      __$$LoadProductDetailImplCopyWithImpl<_$LoadProductDetailImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? search) loadProducts,
    required TResult Function(String id) loadProductDetail,
    required TResult Function(String name, String description, double price,
            int stock, String imageUrl, String category)
        createProduct,
    required TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)
        updateProduct,
    required TResult Function(String id) deleteProduct,
  }) {
    return loadProductDetail(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? search)? loadProducts,
    TResult? Function(String id)? loadProductDetail,
    TResult? Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult? Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) {
    return loadProductDetail?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? search)? loadProducts,
    TResult Function(String id)? loadProductDetail,
    TResult Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult Function(String id)? deleteProduct,
    required TResult orElse(),
  }) {
    if (loadProductDetail != null) {
      return loadProductDetail(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProducts value) loadProducts,
    required TResult Function(LoadProductDetail value) loadProductDetail,
    required TResult Function(CreateProductEvent value) createProduct,
    required TResult Function(UpdateProductEvent value) updateProduct,
    required TResult Function(DeleteProductEvent value) deleteProduct,
  }) {
    return loadProductDetail(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProducts value)? loadProducts,
    TResult? Function(LoadProductDetail value)? loadProductDetail,
    TResult? Function(CreateProductEvent value)? createProduct,
    TResult? Function(UpdateProductEvent value)? updateProduct,
    TResult? Function(DeleteProductEvent value)? deleteProduct,
  }) {
    return loadProductDetail?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProducts value)? loadProducts,
    TResult Function(LoadProductDetail value)? loadProductDetail,
    TResult Function(CreateProductEvent value)? createProduct,
    TResult Function(UpdateProductEvent value)? updateProduct,
    TResult Function(DeleteProductEvent value)? deleteProduct,
    required TResult orElse(),
  }) {
    if (loadProductDetail != null) {
      return loadProductDetail(this);
    }
    return orElse();
  }
}

abstract class LoadProductDetail implements ProductEvent {
  const factory LoadProductDetail(final String id) = _$LoadProductDetailImpl;

  String get id;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadProductDetailImplCopyWith<_$LoadProductDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CreateProductEventImplCopyWith<$Res> {
  factory _$$CreateProductEventImplCopyWith(_$CreateProductEventImpl value,
          $Res Function(_$CreateProductEventImpl) then) =
      __$$CreateProductEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String name,
      String description,
      double price,
      int stock,
      String imageUrl,
      String category});
}

/// @nodoc
class __$$CreateProductEventImplCopyWithImpl<$Res>
    extends _$ProductEventCopyWithImpl<$Res, _$CreateProductEventImpl>
    implements _$$CreateProductEventImplCopyWith<$Res> {
  __$$CreateProductEventImplCopyWithImpl(_$CreateProductEventImpl _value,
      $Res Function(_$CreateProductEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? stock = null,
    Object? imageUrl = null,
    Object? category = null,
  }) {
    return _then(_$CreateProductEventImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CreateProductEventImpl implements CreateProductEvent {
  const _$CreateProductEventImpl(
      {required this.name,
      required this.description,
      required this.price,
      required this.stock,
      required this.imageUrl,
      required this.category});

  @override
  final String name;
  @override
  final String description;
  @override
  final double price;
  @override
  final int stock;
  @override
  final String imageUrl;
  @override
  final String category;

  @override
  String toString() {
    return 'ProductEvent.createProduct(name: $name, description: $description, price: $price, stock: $stock, imageUrl: $imageUrl, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateProductEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, name, description, price, stock, imageUrl, category);

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateProductEventImplCopyWith<_$CreateProductEventImpl> get copyWith =>
      __$$CreateProductEventImplCopyWithImpl<_$CreateProductEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? search) loadProducts,
    required TResult Function(String id) loadProductDetail,
    required TResult Function(String name, String description, double price,
            int stock, String imageUrl, String category)
        createProduct,
    required TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)
        updateProduct,
    required TResult Function(String id) deleteProduct,
  }) {
    return createProduct(name, description, price, stock, imageUrl, category);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? search)? loadProducts,
    TResult? Function(String id)? loadProductDetail,
    TResult? Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult? Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) {
    return createProduct?.call(
        name, description, price, stock, imageUrl, category);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? search)? loadProducts,
    TResult Function(String id)? loadProductDetail,
    TResult Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult Function(String id)? deleteProduct,
    required TResult orElse(),
  }) {
    if (createProduct != null) {
      return createProduct(name, description, price, stock, imageUrl, category);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProducts value) loadProducts,
    required TResult Function(LoadProductDetail value) loadProductDetail,
    required TResult Function(CreateProductEvent value) createProduct,
    required TResult Function(UpdateProductEvent value) updateProduct,
    required TResult Function(DeleteProductEvent value) deleteProduct,
  }) {
    return createProduct(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProducts value)? loadProducts,
    TResult? Function(LoadProductDetail value)? loadProductDetail,
    TResult? Function(CreateProductEvent value)? createProduct,
    TResult? Function(UpdateProductEvent value)? updateProduct,
    TResult? Function(DeleteProductEvent value)? deleteProduct,
  }) {
    return createProduct?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProducts value)? loadProducts,
    TResult Function(LoadProductDetail value)? loadProductDetail,
    TResult Function(CreateProductEvent value)? createProduct,
    TResult Function(UpdateProductEvent value)? updateProduct,
    TResult Function(DeleteProductEvent value)? deleteProduct,
    required TResult orElse(),
  }) {
    if (createProduct != null) {
      return createProduct(this);
    }
    return orElse();
  }
}

abstract class CreateProductEvent implements ProductEvent {
  const factory CreateProductEvent(
      {required final String name,
      required final String description,
      required final double price,
      required final int stock,
      required final String imageUrl,
      required final String category}) = _$CreateProductEventImpl;

  String get name;
  String get description;
  double get price;
  int get stock;
  String get imageUrl;
  String get category;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateProductEventImplCopyWith<_$CreateProductEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateProductEventImplCopyWith<$Res> {
  factory _$$UpdateProductEventImplCopyWith(_$UpdateProductEventImpl value,
          $Res Function(_$UpdateProductEventImpl) then) =
      __$$UpdateProductEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String id,
      String? name,
      String? description,
      double? price,
      int? stock,
      String? imageUrl,
      String? category});
}

/// @nodoc
class __$$UpdateProductEventImplCopyWithImpl<$Res>
    extends _$ProductEventCopyWithImpl<$Res, _$UpdateProductEventImpl>
    implements _$$UpdateProductEventImplCopyWith<$Res> {
  __$$UpdateProductEventImplCopyWithImpl(_$UpdateProductEventImpl _value,
      $Res Function(_$UpdateProductEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? price = freezed,
    Object? stock = freezed,
    Object? imageUrl = freezed,
    Object? category = freezed,
  }) {
    return _then(_$UpdateProductEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      stock: freezed == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UpdateProductEventImpl implements UpdateProductEvent {
  const _$UpdateProductEventImpl(
      {required this.id,
      this.name,
      this.description,
      this.price,
      this.stock,
      this.imageUrl,
      this.category});

  @override
  final String id;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final double? price;
  @override
  final int? stock;
  @override
  final String? imageUrl;
  @override
  final String? category;

  @override
  String toString() {
    return 'ProductEvent.updateProduct(id: $id, name: $name, description: $description, price: $price, stock: $stock, imageUrl: $imageUrl, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateProductEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, description, price, stock, imageUrl, category);

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateProductEventImplCopyWith<_$UpdateProductEventImpl> get copyWith =>
      __$$UpdateProductEventImplCopyWithImpl<_$UpdateProductEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? search) loadProducts,
    required TResult Function(String id) loadProductDetail,
    required TResult Function(String name, String description, double price,
            int stock, String imageUrl, String category)
        createProduct,
    required TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)
        updateProduct,
    required TResult Function(String id) deleteProduct,
  }) {
    return updateProduct(
        id, name, description, price, stock, imageUrl, category);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? search)? loadProducts,
    TResult? Function(String id)? loadProductDetail,
    TResult? Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult? Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) {
    return updateProduct?.call(
        id, name, description, price, stock, imageUrl, category);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? search)? loadProducts,
    TResult Function(String id)? loadProductDetail,
    TResult Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult Function(String id)? deleteProduct,
    required TResult orElse(),
  }) {
    if (updateProduct != null) {
      return updateProduct(
          id, name, description, price, stock, imageUrl, category);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProducts value) loadProducts,
    required TResult Function(LoadProductDetail value) loadProductDetail,
    required TResult Function(CreateProductEvent value) createProduct,
    required TResult Function(UpdateProductEvent value) updateProduct,
    required TResult Function(DeleteProductEvent value) deleteProduct,
  }) {
    return updateProduct(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProducts value)? loadProducts,
    TResult? Function(LoadProductDetail value)? loadProductDetail,
    TResult? Function(CreateProductEvent value)? createProduct,
    TResult? Function(UpdateProductEvent value)? updateProduct,
    TResult? Function(DeleteProductEvent value)? deleteProduct,
  }) {
    return updateProduct?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProducts value)? loadProducts,
    TResult Function(LoadProductDetail value)? loadProductDetail,
    TResult Function(CreateProductEvent value)? createProduct,
    TResult Function(UpdateProductEvent value)? updateProduct,
    TResult Function(DeleteProductEvent value)? deleteProduct,
    required TResult orElse(),
  }) {
    if (updateProduct != null) {
      return updateProduct(this);
    }
    return orElse();
  }
}

abstract class UpdateProductEvent implements ProductEvent {
  const factory UpdateProductEvent(
      {required final String id,
      final String? name,
      final String? description,
      final double? price,
      final int? stock,
      final String? imageUrl,
      final String? category}) = _$UpdateProductEventImpl;

  String get id;
  String? get name;
  String? get description;
  double? get price;
  int? get stock;
  String? get imageUrl;
  String? get category;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateProductEventImplCopyWith<_$UpdateProductEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteProductEventImplCopyWith<$Res> {
  factory _$$DeleteProductEventImplCopyWith(_$DeleteProductEventImpl value,
          $Res Function(_$DeleteProductEventImpl) then) =
      __$$DeleteProductEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$DeleteProductEventImplCopyWithImpl<$Res>
    extends _$ProductEventCopyWithImpl<$Res, _$DeleteProductEventImpl>
    implements _$$DeleteProductEventImplCopyWith<$Res> {
  __$$DeleteProductEventImplCopyWithImpl(_$DeleteProductEventImpl _value,
      $Res Function(_$DeleteProductEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$DeleteProductEventImpl(
      null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DeleteProductEventImpl implements DeleteProductEvent {
  const _$DeleteProductEventImpl(this.id);

  @override
  final String id;

  @override
  String toString() {
    return 'ProductEvent.deleteProduct(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteProductEventImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteProductEventImplCopyWith<_$DeleteProductEventImpl> get copyWith =>
      __$$DeleteProductEventImplCopyWithImpl<_$DeleteProductEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? search) loadProducts,
    required TResult Function(String id) loadProductDetail,
    required TResult Function(String name, String description, double price,
            int stock, String imageUrl, String category)
        createProduct,
    required TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)
        updateProduct,
    required TResult Function(String id) deleteProduct,
  }) {
    return deleteProduct(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? search)? loadProducts,
    TResult? Function(String id)? loadProductDetail,
    TResult? Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult? Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult? Function(String id)? deleteProduct,
  }) {
    return deleteProduct?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? search)? loadProducts,
    TResult Function(String id)? loadProductDetail,
    TResult Function(String name, String description, double price, int stock,
            String imageUrl, String category)?
        createProduct,
    TResult Function(String id, String? name, String? description,
            double? price, int? stock, String? imageUrl, String? category)?
        updateProduct,
    TResult Function(String id)? deleteProduct,
    required TResult orElse(),
  }) {
    if (deleteProduct != null) {
      return deleteProduct(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadProducts value) loadProducts,
    required TResult Function(LoadProductDetail value) loadProductDetail,
    required TResult Function(CreateProductEvent value) createProduct,
    required TResult Function(UpdateProductEvent value) updateProduct,
    required TResult Function(DeleteProductEvent value) deleteProduct,
  }) {
    return deleteProduct(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadProducts value)? loadProducts,
    TResult? Function(LoadProductDetail value)? loadProductDetail,
    TResult? Function(CreateProductEvent value)? createProduct,
    TResult? Function(UpdateProductEvent value)? updateProduct,
    TResult? Function(DeleteProductEvent value)? deleteProduct,
  }) {
    return deleteProduct?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadProducts value)? loadProducts,
    TResult Function(LoadProductDetail value)? loadProductDetail,
    TResult Function(CreateProductEvent value)? createProduct,
    TResult Function(UpdateProductEvent value)? updateProduct,
    TResult Function(DeleteProductEvent value)? deleteProduct,
    required TResult orElse(),
  }) {
    if (deleteProduct != null) {
      return deleteProduct(this);
    }
    return orElse();
  }
}

abstract class DeleteProductEvent implements ProductEvent {
  const factory DeleteProductEvent(final String id) = _$DeleteProductEventImpl;

  String get id;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteProductEventImplCopyWith<_$DeleteProductEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
