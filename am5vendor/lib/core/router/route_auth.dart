import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/injection_container.dart' as di;
import '../services/auth_storage_service.dart';
import 'app_routes.dart';

const Set<String> kPublicRoutePaths = {
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.employeeLogin,
  AppRoutes.privacyPolicy,
  AppRoutes.termsConditions,
  AppRoutes.helpSupport,
  AppRoutes.deleteAccountPolicy,
  AppRoutes.forceUpdate,
};

bool isPublicRoute(String location) {
  if (kPublicRoutePaths.contains(location)) return true;
  return false;
}

bool isAuthEntryRoute(String location) {
  return location == AppRoutes.login ||
      location == AppRoutes.employeeLogin;
}

/// Global auth guard for go_router.
String? authRedirectGuard(BuildContext context, GoRouterState state) {
  if (!di.sl.isRegistered<AuthStorageService>()) {
    return null;
  }

  final authStorage = di.sl<AuthStorageService>();
  final bool isLoggedIn = authStorage.isLoggedIn();
  final String location = state.uri.path;

  if (!isLoggedIn && !isPublicRoute(location)) {
    if (kDebugMode) {
      debugPrint(
        'AuthGuard: denied $location without auth -> ${AppRoutes.login}',
      );
    }
    return AppRoutes.login;
  }

  if (isLoggedIn && isAuthEntryRoute(location)) {
    final fromLogout = state.uri.queryParameters['fromLogout'] == 'true';
    if (!fromLogout) {
      return AppRoutes.splash;
    }
  }

  return null;
}
