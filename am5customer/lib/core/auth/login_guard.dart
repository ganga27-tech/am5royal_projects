import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

bool routeRequiresAuth(String location) {
  if (location == '/bookings' || location.startsWith('/bookings/')) return true;
  if (location == '/notifications' || location == '/wallet') return true;
  if (location.startsWith('/profile/edit') ||
      location.startsWith('/profile/addresses')) {
    return true;
  }
  if (location.startsWith('/addresses')) return true;
  return false;
}

bool isPublicAppRoute(String location) {
  if (location == '/welcome' || location == '/login' || location == '/otp') {
    return true;
  }
  if (location == '/home' ||
      location == '/search' ||
      location == '/assistant' ||
      location == '/profile' ||
      location == '/support' ||
      location == '/settings') {
    return true;
  }
  if (location == '/book' || location == '/booking-confirmed') return true;
  if (location.startsWith('/shop')) return true;
  if (location.startsWith('/professionals') ||
      location.startsWith('/vendors') ||
      location.startsWith('/services') ||
      location.startsWith('/categories')) {
    return true;
  }
  return false;
}

String? resolveAppRedirect({
  required AuthStatus authStatus,
  required String location,
  String? redirectQueryParam,
}) {
  final loc = location;
  final onAuthFlow =
      loc == '/splash' ||
      loc == '/welcome' ||
      loc == '/login' ||
      loc == '/otp';
  final isGuestBookingFlow =
      loc == '/book' ||
      loc == '/booking-confirmed' ||
      loc.startsWith('/professionals') ||
      loc.startsWith('/vendors') ||
      loc.startsWith('/services') ||
      loc.startsWith('/categories');
  final needsAuth = routeRequiresAuth(loc);

  // 1. Initial cold-start check before AuthBloc has started:
  if (authStatus == AuthStatus.unknown) {
    return loc == '/splash' ? null : '/splash';
  }

  // 2. On /splash:
  if (loc == '/splash') {
    // Keep showing splash if initial session check is actively running
    if (authStatus == AuthStatus.loading) {
      return null;
    }
    if (authStatus == AuthStatus.authenticated) {
      return '/home';
    }
    return '/welcome';
  }

  // 3. In-page loading states (e.g. sending OTP on /login, verifying on /otp):
  // Never redirect away from the user's active page while an action is loading!
  if (authStatus == AuthStatus.loading) {
    return null;
  }

  // 4. Authenticated:
  if (authStatus == AuthStatus.authenticated) {
    if (loc == '/welcome' || loc == '/login') {
      if (redirectQueryParam != null && redirectQueryParam.isNotEmpty) {
        return redirectQueryParam;
      }
      return '/home';
    }
    return null;
  }

  // 5. Unauthenticated:
  if (needsAuth) {
    return '/login?redirect=${Uri.encodeComponent(loc)}';
  }
  if (isPublicAppRoute(loc) || isGuestBookingFlow) return null;
  if (!onAuthFlow && loc != '/welcome') return '/welcome';
  return null;
}


abstract final class LoginGuard {
  static bool isAuthenticated(BuildContext context) =>
      context.read<AuthBloc>().state.status == AuthStatus.authenticated;

  static Future<bool> ensureLoggedIn(
    BuildContext context, {
    String message = 'Please sign in to continue.',
    String? redirectTo,
  }) async {
    if (isAuthenticated(context)) return true;

    final login = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign in required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );

    if (login == true && context.mounted) {
      final returnPath = redirectTo ?? GoRouterState.of(context).uri.toString();
      context.push('/login?redirect=${Uri.encodeComponent(returnPath)}');
    }
    return false;
  }

  static Future<void> runProtected(
    BuildContext context,
    VoidCallback action, {
    String message = 'Please sign in to continue.',
    String? redirectTo,
  }) async {
    if (isAuthenticated(context)) {
      action();
      return;
    }
    final ok = await ensureLoggedIn(
      context,
      message: message,
      redirectTo: redirectTo,
    );
    if (ok && context.mounted && isAuthenticated(context)) {
      action();
    }
  }
}
