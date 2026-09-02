import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../client/api_client.dart';

/// Shop adapter — AM5 service packages as products with a local cart.
class MarketplaceApi {
  MarketplaceApi(this._client);

  final ApiClient _client;

  static const _cartKey = 'am5_shop_cart';
  static const _ordersKey = 'am5_shop_orders';

  Future<List<MarketplaceProduct>> _loadPackages({
    String? category,
    String? q,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _client.dio.get(
      '/catalog/packages',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (category != null && category != 'packages') 'subcategory_id': category,
      },
    );
    var list = (response.data as List<dynamic>)
        .map((e) => MarketplaceProduct.fromAm5Package(e as Map<String, dynamic>))
        .toList();
    if (q != null && q.isNotEmpty) {
      final query = q.toLowerCase();
      list = list
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }
    return list;
  }

  Future<List<MarketplaceProduct>> listProducts({
    String? category,
    String? q,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _loadPackages(category: category, q: q, limit: limit, offset: offset);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<MarketplaceProduct> getProduct(String id) async {
    try {
      final products = await _loadPackages(limit: 200);
      return products.firstWhere(
        (p) => p.id == id,
        orElse: () => throw const Failure('Product not found'),
      );
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<ShoppingCart> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);
    final items = raw == null
        ? <Map<String, dynamic>>[]
        : (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    if (items.isEmpty) {
      return const ShoppingCart(
        id: 'local-cart',
        items: [],
        itemCount: 0,
        subtotalAmount: 0,
        currency: 'INR',
      );
    }

    final products = await _loadPackages(limit: 200);
    final byId = {for (final p in products) p.id: p};
    final cartItems = <CartItem>[];
    var subtotal = 0.0;
    for (final entry in items) {
      final productId = entry['product_id'] as String;
      final quantity = entry['quantity'] as int? ?? 1;
      final product = byId[productId];
      if (product == null) continue;
      cartItems.add(CartItem(productId: productId, quantity: quantity, product: product));
      subtotal += product.priceAmount * quantity;
    }
    return ShoppingCart(
      id: 'local-cart',
      items: cartItems,
      itemCount: cartItems.fold<int>(0, (sum, i) => sum + i.quantity),
      subtotalAmount: subtotal,
      currency: 'INR',
    );
  }

  Future<ShoppingCart> upsertCartItem({
    required String productId,
    required int quantity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);
    final items = raw == null
        ? <Map<String, dynamic>>[]
        : (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();

    final updated = [
      for (final entry in items.where((e) => e['product_id'] != productId)) entry,
      if (quantity > 0) {'product_id': productId, 'quantity': quantity},
    ];
    await prefs.setString(_cartKey, jsonEncode(updated));
    return getCart();
  }

  Future<ShoppingCart> removeCartItem(String productId) async {
    return upsertCartItem(productId: productId, quantity: 0);
  }

  Future<ProductOrder> checkout({
    String? addressId,
    double useWalletAmount = 0,
  }) async {
    final cart = await getCart();
    if (cart.items.isEmpty) {
      throw const Failure('Your cart is empty');
    }

    final order = ProductOrder(
      id: 'shop-${DateTime.now().millisecondsSinceEpoch}',
      status: 'pending_booking',
      paymentStatus: 'cod',
      subtotalAmount: cart.subtotalAmount,
      walletAmount: useWalletAmount,
      gatewayAmount: cart.subtotalAmount - useWalletAmount,
      totalAmount: cart.subtotalAmount,
      currency: cart.currency,
      items: cart.items
          .map(
            (i) => ProductOrderItem(
              id: i.productId,
              productId: i.productId,
              productName: i.product.name,
              unitPrice: i.product.priceAmount,
              quantity: i.quantity,
              lineTotal: i.product.priceAmount * i.quantity,
            ),
          )
          .toList(),
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_ordersKey) ?? [];
    existing.insert(0, jsonEncode({
      'id': order.id,
      'status': order.status,
      'payment_status': order.paymentStatus,
      'subtotal_amount': order.subtotalAmount,
      'wallet_amount': order.walletAmount,
      'gateway_amount': order.gatewayAmount,
      'total_amount': order.totalAmount,
      'currency': order.currency,
      'created_at': order.createdAt,
      'items': order.items
          .map(
            (i) => {
              'id': i.id,
              'product_id': i.productId,
              'product_name': i.productName,
              'unit_price': i.unitPrice,
              'quantity': i.quantity,
              'line_total': i.lineTotal,
            },
          )
          .toList(),
    }));
    await prefs.setStringList(_ordersKey, existing.take(20).toList());
    await prefs.remove(_cartKey);
    return order;
  }

  Future<List<ProductOrder>> listOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_ordersKey) ?? [];
    return stored
        .map((e) => ProductOrder.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<ProductOrder> getOrder(String id) async {
    final orders = await listOrders();
    return orders.firstWhere(
      (o) => o.id == id,
      orElse: () => throw const Failure('Order not found'),
    );
  }

  Future<List<MarketplaceProduct>> listPartnerProducts() async {
    throw const Failure('Partner products are not available in the customer app.');
  }

  Future<MarketplaceProduct> createPartnerProduct({
    required String name,
    String? shortDescription,
    String? description,
    String category = 'general',
    String? imageUrl,
    required double priceAmount,
    int stockQuantity = 0,
    String unitLabel = 'piece',
  }) async {
    throw const Failure('Partner products are not available in the customer app.');
  }

  Future<MarketplaceProduct> updatePartnerProduct(
    String id, {
    String? name,
    String? shortDescription,
    String? description,
    String? category,
    String? imageUrl,
    double? priceAmount,
    int? stockQuantity,
    String? unitLabel,
    bool? isActive,
  }) async {
    throw const Failure('Partner products are not available in the customer app.');
  }

  Future<void> deletePartnerProduct(String id) async {
    throw const Failure('Partner products are not available in the customer app.');
  }
}
