import 'package:flutter_test/flutter_test.dart';
import 'package:am5customer/core/auth/login_guard.dart';

void main() {
  group('Route Guards', () {
    test('/splash is not a public browsing route', () {
      expect(isPublicAppRoute('/splash'), isFalse);
    });

    test('welcome, login, and otp are public routes', () {
      expect(isPublicAppRoute('/welcome'), isTrue);
      expect(isPublicAppRoute('/login'), isTrue);
      expect(isPublicAppRoute('/otp'), isTrue);
    });

    test('home and catalog pages are public routes', () {
      expect(isPublicAppRoute('/home'), isTrue);
      expect(isPublicAppRoute('/search'), isTrue);
      expect(isPublicAppRoute('/categories/123'), isTrue);
      expect(isPublicAppRoute('/services/456'), isTrue);
      expect(isPublicAppRoute('/professionals'), isTrue);
      expect(isPublicAppRoute('/vendors/789'), isTrue);
    });

    test('protected routes require authentication', () {
      expect(routeRequiresAuth('/bookings'), isTrue);
      expect(routeRequiresAuth('/bookings/123'), isTrue);
      expect(routeRequiresAuth('/wallet'), isTrue);
      expect(routeRequiresAuth('/notifications'), isTrue);
      expect(routeRequiresAuth('/profile/edit'), isTrue);
      expect(routeRequiresAuth('/addresses'), isTrue);
      expect(routeRequiresAuth('/splash'), isFalse);
      expect(routeRequiresAuth('/home'), isFalse);
      expect(routeRequiresAuth('/welcome'), isFalse);
    });
  });
}
