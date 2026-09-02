import 'package:equatable/equatable.dart';

class MarketplaceProduct extends Equatable {
  const MarketplaceProduct({
    required this.id,
    required this.professionalId,
    required this.name,
    required this.slug,
    required this.category,
    required this.priceAmount,
    required this.currency,
    required this.stockQuantity,
    required this.unitLabel,
    required this.isActive,
    required this.status,
    this.vendorName,
    this.shortDescription,
    this.description,
    this.imageUrl,
    this.rejectionReason,
  });

  final String id;
  final String professionalId;
  final String? vendorName;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String category;
  final String? imageUrl;
  final double priceAmount;
  final String currency;
  final int stockQuantity;
  final String unitLabel;
  final bool isActive;
  final String status;
  final String? rejectionReason;

  factory MarketplaceProduct.fromAm5Package(Map<String, dynamic> json) {
    final price = json['price'] ?? json['mrp'];
    return MarketplaceProduct(
      id: json['id']?.toString() ?? '',
      professionalId: json['subcategory_id']?.toString() ?? '0',
      name: json['title'] as String? ?? json['name'] as String? ?? 'Package',
      slug: json['id']?.toString() ?? '',
      shortDescription: json['detailInfo'] as String?,
      description: json['detailInfo'] as String?,
      category: 'packages',
      imageUrl: json['heroImage'] as String?,
      priceAmount: price is num ? price.toDouble() : double.tryParse('$price') ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      stockQuantity: 99,
      unitLabel: 'service',
      isActive: json['is_active'] as bool? ?? true,
      status: 'approved',
    );
  }

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    final price = json['price_amount'];
    return MarketplaceProduct(
      id: json['id']?.toString() ?? '',
      professionalId: json['professional_id'] as String,
      vendorName: json['vendor_name'] as String?,
      name: json['name'] as String,
      slug: json['slug'] as String,
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
      priceAmount: price is num ? price.toDouble() : double.parse('$price'),
      currency: json['currency'] as String? ?? 'INR',
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      unitLabel: json['unit_label'] as String? ?? 'piece',
      isActive: json['is_active'] as bool? ?? true,
      status: json['status'] as String? ?? 'approved',
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, slug, name, priceAmount];
}

class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.quantity,
    required this.product,
  });

  final String productId;
  final int quantity;
  final MarketplaceProduct product;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int? ?? 1,
      product: MarketplaceProduct.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [productId, quantity];
}

class ShoppingCart extends Equatable {
  const ShoppingCart({
    required this.id,
    required this.items,
    required this.itemCount,
    required this.subtotalAmount,
    required this.currency,
  });

  final String id;
  final List<CartItem> items;
  final int itemCount;
  final double subtotalAmount;
  final String currency;

  factory ShoppingCart.fromJson(Map<String, dynamic> json) {
    final subtotal = json['subtotal_amount'];
    return ShoppingCart(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemCount: json['item_count'] as int? ?? 0,
      subtotalAmount: subtotal is num ? subtotal.toDouble() : double.parse('$subtotal'),
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  @override
  List<Object?> get props => [id, itemCount, subtotalAmount];
}

class ProductOrderItem extends Equatable {
  const ProductOrderItem({
    required this.id,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.productId,
    this.professionalId,
  });

  final String id;
  final String? productId;
  final String? professionalId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  factory ProductOrderItem.fromJson(Map<String, dynamic> json) {
    final unit = json['unit_price'];
    final line = json['line_total'];
    return ProductOrderItem(
      id: json['id'] as String,
      productId: json['product_id'] as String?,
      professionalId: json['professional_id'] as String?,
      productName: json['product_name'] as String,
      unitPrice: unit is num ? unit.toDouble() : double.parse('$unit'),
      quantity: json['quantity'] as int? ?? 1,
      lineTotal: line is num ? line.toDouble() : double.parse('$line'),
    );
  }

  @override
  List<Object?> get props => [id, productName];
}

class ProductOrder extends Equatable {
  const ProductOrder({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.subtotalAmount,
    required this.walletAmount,
    required this.gatewayAmount,
    required this.totalAmount,
    required this.currency,
    required this.items,
    required this.createdAt,
    this.paidAt,
    this.deliveryAddressSnapshot,
  });

  final String id;
  final String status;
  final String paymentStatus;
  final double subtotalAmount;
  final double walletAmount;
  final double gatewayAmount;
  final double totalAmount;
  final String currency;
  final String? paidAt;
  final String? deliveryAddressSnapshot;
  final List<ProductOrderItem> items;
  final String createdAt;

  factory ProductOrder.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic v) => v is num ? v.toDouble() : double.parse('$v');
    return ProductOrder(
      id: json['id'] as String,
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
      subtotalAmount: parseAmount(json['subtotal_amount']),
      walletAmount: parseAmount(json['wallet_amount']),
      gatewayAmount: parseAmount(json['gateway_amount']),
      totalAmount: parseAmount(json['total_amount']),
      currency: json['currency'] as String? ?? 'INR',
      paidAt: json['paid_at'] as String?,
      deliveryAddressSnapshot: json['delivery_address_snapshot'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ProductOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, status, totalAmount];
}
