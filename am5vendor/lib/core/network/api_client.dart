import 'package:dio/dio.dart';
import '../../features/products/data/models/product_model.dart';
import 'dio_factory.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio) {
    if (useMockApiInterceptor) {
      dio.interceptors.insert(0, MockApiInterceptor());
    }
  }
}

class MockApiInterceptor extends Interceptor {
  // In-memory data store for products loaded from ProductModel sample data and subcategory products
  final List<Map<String, dynamic>> _products = [
    ...ProductModel.sampleProducts.map((p) => p.toJson()),
    {
      'id': 'home_ac_repair',
      'name': 'AC Repair Service',
      'description':
          'Professional split/window AC repair, diagnosis, gas charging, and servicing.',
      'price': 49.99,
      'stock': 40,
      'imageUrl':
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500&auto=format&fit=crop&q=60',
      'category': 'Home Services',
    },
    {
      'id': 'home_ac_compressor',
      'name': 'AC Compressor Repair',
      'description':
          'High-quality compressor winding repair, replacement, and vacuum testing services.',
      'price': 129.99,
      'stock': 15,
      'imageUrl':
          'https://images.unsplash.com/photo-1581094288338-2314dddb7ecc?w=500&auto=format&fit=crop&q=60',
      'category': 'Home Services',
    },
    {
      'id': 'home_fan_motor',
      'name': 'Fan Motor Repair',
      'description':
          'Ceiling fan, exhaust fan, and cooler fan motor rewinding and bearing replacement.',
      'price': 24.99,
      'stock': 80,
      'imageUrl':
          'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=500&auto=format&fit=crop&q=60',
      'category': 'Home Services',
    },
    {
      'id': 'home_appliance',
      'name': 'Appliance Repair',
      'description':
          'Doorstep repair services for washing machines, refrigerators, microwaves, and chimneys.',
      'price': 59.99,
      'stock': 25,
      'imageUrl':
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500&auto=format&fit=crop&q=60',
      'category': 'Home Services',
    },
    {
      'id': 'home_electrical',
      'name': 'Electrical Services',
      'description':
          'Installation and repair of switches, sockets, distribution boards, wiring, and light fixtures.',
      'price': 39.99,
      'stock': 65,
      'imageUrl':
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500&auto=format&fit=crop&q=60',
      'category': 'Home Services',
    },
    {
      'id': 'home_plumbing',
      'name': 'Plumbing Services',
      'description':
          'Fixing water leaks, pipeline installation, blockages removal, and sanitary fittings.',
      'price': 44.99,
      'stock': 50,
      'imageUrl':
          'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=500&auto=format&fit=crop&q=60',
      'category': 'Home Services',
    },
    {
      'id': 'home_pest_control',
      'name': 'Pest Control Services',
      'description':
          'Eco-friendly termite, bedbug, cockroach, rodent, and general pest control spraying.',
      'price': 79.99,
      'stock': 35,
      'imageUrl':
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500&auto=format&fit=crop&q=60',
      'category': 'Home Services',
    },
    {
      'id': 'home_support',
      'name': '24/7 Support',
      'description':
          'Round-the-clock emergency support, inspection, and helper dispatch for urgent home breakdowns.',
      'price': 19.99,
      'stock': 120,
      'imageUrl':
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500&auto=format&fit=crop&q=60',
      'category': 'Home Services',
    },
  ];

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;
    final method = options.method;

    if (!_isMockRoute(path, method)) {
      return super.onRequest(options, handler);
    }

    // Small delay only for in-memory mock routes (dev debug builds)
    await Future.delayed(const Duration(milliseconds: 80));

    // Route: GET /products
    if (path == '/products' && method == 'GET') {
      final queryParams = options.queryParameters;
      var filteredList = List<Map<String, dynamic>>.from(_products);

      if (queryParams.containsKey('search') && queryParams['search'] != null) {
        final searchStr = queryParams['search'].toString().toLowerCase();
        final searchTerms = searchStr.contains(',')
            ? searchStr
                .split(',')
                .map((term) => term.trim())
                .where((t) => t.isNotEmpty)
                .toList()
            : [searchStr];
        filteredList = filteredList.where((p) {
          final name = p['name'].toString().toLowerCase();
          final desc = p['description'].toString().toLowerCase();
          final cat = p['category'].toString().toLowerCase();
          return searchTerms.any((term) =>
              name.contains(term) || desc.contains(term) || cat.contains(term));
        }).toList();
      }

      handler.resolve(Response(
        requestOptions: options,
        data: filteredList,
        statusCode: 200,
      ));
      return;
    }

    // Route: GET /products/:id
    final getMatch = RegExp(r'^/products/([^/]+)$').firstMatch(path);
    if (getMatch != null && method == 'GET') {
      final id = getMatch.group(1);
      final product = _products.firstWhere(
        (p) => p['id'] == id,
        orElse: () => throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 404,
            data: {'message': 'Product with ID $id not found.'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      handler.resolve(Response(
        requestOptions: options,
        data: product,
        statusCode: 200,
      ));
      return;
    }

    // Route: POST /products
    if (path == '/products' && method == 'POST') {
      final body = options.data;
      if (body is! Map<String, dynamic>) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'Invalid request body.'},
          ),
        ));
        return;
      }

      // Check required fields
      if (!body.containsKey('name') || body['name'].toString().trim().isEmpty) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'Product name is required.'},
          ),
        ));
        return;
      }

      final newProduct = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': body['name'],
        'description': body['description'] ?? '',
        'price': (body['price'] as num?)?.toDouble() ?? 0.0,
        'stock': (body['stock'] as num?)?.toInt() ?? 0,
        'imageUrl': body['imageUrl'] ??
            'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
        'category': body['category'] ?? 'General',
      };

      _products.add(newProduct);

      handler.resolve(Response(
        requestOptions: options,
        data: newProduct,
        statusCode: 201,
      ));
      return;
    }

    // Route: PUT /products/:id
    final putMatch = RegExp(r'^/products/([^/]+)$').firstMatch(path);
    if (putMatch != null && method == 'PUT') {
      final id = putMatch.group(1);
      final body = options.data;

      if (body is! Map<String, dynamic>) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'Invalid request body.'},
          ),
        ));
        return;
      }

      final index = _products.indexWhere((p) => p['id'] == id);
      if (index == -1) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 404,
            data: {'message': 'Product with ID $id not found.'},
          ),
          type: DioExceptionType.badResponse,
        ));
        return;
      }

      // Update existing item fields
      final updatedProduct = {
        ..._products[index],
        if (body.containsKey('name')) 'name': body['name'],
        if (body.containsKey('description')) 'description': body['description'],
        if (body.containsKey('price'))
          'price': (body['price'] as num?)?.toDouble(),
        if (body.containsKey('stock'))
          'stock': (body['stock'] as num?)?.toInt(),
        if (body.containsKey('imageUrl')) 'imageUrl': body['imageUrl'],
        if (body.containsKey('category')) 'category': body['category'],
      };

      _products[index] = updatedProduct;

      handler.resolve(Response(
        requestOptions: options,
        data: updatedProduct,
        statusCode: 200,
      ));
      return;
    }

    // Route: DELETE /products/:id
    final deleteMatch = RegExp(r'^/products/([^/]+)$').firstMatch(path);
    if (deleteMatch != null && method == 'DELETE') {
      final id = deleteMatch.group(1);
      final index = _products.indexWhere((p) => p['id'] == id);

      if (index == -1) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 404,
            data: {'message': 'Product with ID $id not found.'},
          ),
          type: DioExceptionType.badResponse,
        ));
        return;
      }

      final deletedProduct = _products.removeAt(index);

      handler.resolve(Response(
        requestOptions: options,
        data: deletedProduct,
        statusCode: 200,
      ));
      return;
    }

    // Route: POST /auth/login
    if (path == '/auth/login' && method == 'POST') {
      final body = options.data;
      if (body is! Map<String, dynamic>) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'Invalid request body.'},
          ),
        ));
        return;
      }

      final contact = body['contact']?.toString().trim();
      final otp = body['otp']?.toString().trim();

      if (contact == null || contact.isEmpty) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'Mobile number or email is required.'},
          ),
        ));
        return;
      }

      if (otp == null || otp.length != 6) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'A 6-digit OTP is required.'},
          ),
        ));
        return;
      }

      handler.resolve(Response(
        requestOptions: options,
        data: {
          'id': 'vendor_123',
          'contact': contact,
          'token': 'mock_jwt_token_am5_royal',
        },
        statusCode: 200,
      ));
      return;
    }

    // Route: POST /auth/google
    if (path == '/auth/google' && method == 'POST') {
      handler.resolve(Response(
        requestOptions: options,
        data: {
          'id': 'google_vendor_999',
          'contact': 'vendor.royal@gmail.com',
          'token': 'mock_google_jwt_token_am5_royal',
          'name': 'Royal Vendor',
          'email': 'vendor.royal@gmail.com',
          'profile_photo': 'https://lh3.googleusercontent.com/a/default-user',
        },
        statusCode: 200,
      ));
      return;
    }

    // Route: POST /auth/employee/login
    if (path == '/auth/employee/login' && method == 'POST') {
      final body = options.data;
      if (body is! Map<String, dynamic>) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'Invalid request body.'},
          ),
        ));
        return;
      }

      final email = body['email']?.toString().trim();
      final password = body['password']?.toString().trim();

      if (email == null || email.isEmpty) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'Email is required.'},
          ),
        ));
        return;
      }

      if (password == null || password.isEmpty) {
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'Password is required.'},
          ),
        ));
        return;
      }

      handler.resolve(Response(
        requestOptions: options,
        data: {
          'id': 'employee_123',
          'contact': email,
          'token': 'mock_jwt_token_am5_employee',
          'name': 'Royal Employee',
          'email': email,
        },
        statusCode: 200,
      ));
      return;
    }

    // Default: forward request
    super.onRequest(options, handler);
  }

  bool _isMockRoute(String path, String method) {
    if (path == '/products' && method == 'GET') return true;
    if (path == '/products' && method == 'POST') return true;
    if (RegExp(r'^/products/([^/]+)$').hasMatch(path) &&
        (method == 'GET' || method == 'PUT' || method == 'DELETE')) {
      return true;
    }
    if (path == '/auth/login' && method == 'POST') return true;
    if (path == '/auth/google' && method == 'POST') return true;
    if (path == '/auth/employee/login' && method == 'POST') return true;
    return false;
  }
}
