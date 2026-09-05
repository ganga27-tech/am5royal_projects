import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

bool routeRequiresAuth(String location) {
  if (location == '/bookings' || location.startsWith('/bookings/')) return true;
  if (location == '/notifications' || location == '/wallet') return true;
  if (location.startsWith('/profile/edit') || location.startsWith('/profile/addresses')) {
    return true;
  }
  if (location.startsWith('/addresses')) return true;
  return false;
}

bool isPublicAppRoute(String location) {
  if (location == '/splash' ||
      location == '/welcome' ||
      location == '/login' ||
      location == '/otp') {
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
    final ok = await ensureLoggedIn(context, message: message, redirectTo: redirectTo);
    if (ok && context.mounted && isAuthenticated(context)) {
      action();
    }
  }
}
