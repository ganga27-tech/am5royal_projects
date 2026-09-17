import 'package:flutter_test/flutter_test.dart';
import 'package:am5customer/core/auth/login_guard.dart';
import 'package:am5customer/features/auth/presentation/bloc/auth_bloc.dart';

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

  group('resolveAppRedirect', () {
    test('does NOT redirect away from /login during in-page AuthStatus.loading', () {
      final redirect = resolveAppRedirect(
        authStatus: AuthStatus.loading,
        location: '/login',
      );
      expect(redirect, isNull);
    });

    test('does NOT redirect away from /otp during in-page AuthStatus.loading', () {
      final redirect = resolveAppRedirect(
        authStatus: AuthStatus.loading,
        location: '/otp',
      );
      expect(redirect, isNull);
    });

    test('stays on /splash while initial session check is loading', () {
      final redirect = resolveAppRedirect(
        authStatus: AuthStatus.loading,
        location: '/splash',
      );
      expect(redirect, isNull);
    });

    test('redirects from /splash to /welcome when unauthenticated', () {
      final redirect = resolveAppRedirect(
        authStatus: AuthStatus.unauthenticated,
        location: '/splash',
      );
      expect(redirect, '/welcome');
    });

    test('redirects from /splash to /home when authenticated', () {
      final redirect = resolveAppRedirect(
        authStatus: AuthStatus.authenticated,
        location: '/splash',
      );
      expect(redirect, '/home');
    });

    test('redirects from /welcome or /login to /home when authenticated', () {
      expect(
        resolveAppRedirect(
          authStatus: AuthStatus.authenticated,
          location: '/welcome',
        ),
        '/home',
      );
      expect(
        resolveAppRedirect(
          authStatus: AuthStatus.authenticated,
          location: '/login',
        ),
        '/home',
      );
    });

    test('redirects to target redirect param when authenticated from /login', () {
      expect(
        resolveAppRedirect(
          authStatus: AuthStatus.authenticated,
          location: '/login',
          redirectQueryParam: '/shop/cart',
        ),
        '/shop/cart',
      );
    });

    test('allows user to remain on /login and /otp when unauthenticated', () {
      expect(
        resolveAppRedirect(
          authStatus: AuthStatus.unauthenticated,
          location: '/login',
        ),
        isNull,
      );
      expect(
        resolveAppRedirect(
          authStatus: AuthStatus.unauthenticated,
          location: '/otp',
        ),
        isNull,
      );
    });

    test('redirects protected routes to /login when unauthenticated', () {
      expect(
        resolveAppRedirect(
          authStatus: AuthStatus.unauthenticated,
          location: '/bookings',
        ),
        '/login?redirect=%2Fbookings',
      );
    });

    test('redirects cold-start unknown auth to /splash', () {
      expect(
        resolveAppRedirect(
          authStatus: AuthStatus.unknown,
          location: '/home',
        ),
        '/splash',
      );
      expect(
        resolveAppRedirect(
          authStatus: AuthStatus.unknown,
          location: '/splash',
        ),
        isNull,
      );
    });
  });
}

