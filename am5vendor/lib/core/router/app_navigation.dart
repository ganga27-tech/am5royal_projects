import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'app_routes.dart';

extension AppNavigation on BuildContext {
  GoRouter get appNav => appRouter;

  void goTo(String location, {Object? extra}) {
    appRouter.go(location, extra: extra);
  }

  Future<T?> pushTo<T extends Object?>(String location, {Object? extra}) {
    return appRouter.push<T>(location, extra: extra);
  }

  void goLogin({bool fromLogout = false}) {
    final query = fromLogout ? '?fromLogout=true' : '';
    appRouter.go('${AppRoutes.login}$query');
  }

  void goMap({Object? extra}) => appRouter.go(AppRoutes.map, extra: extra);

  void goHome({int initialIndex = 0}) {
    final query = initialIndex == 0 ? '' : '?initialIndex=$initialIndex';
    appRouter.go('${AppRoutes.home}$query');
  }

  void goOrderDetails(int orderId, {Object? extra}) {
    appRouter.push(AppRoutes.orderDetails(orderId), extra: extra);
  }
}
