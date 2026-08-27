import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/orders/presentation/bloc/orders_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/push_notification_service.dart';
import 'features/device_tracking/presentation/bloc/device_tracking_bloc.dart';
import 'features/device_tracking/presentation/bloc/device_tracking_event.dart';
import 'features/earnings/presentation/bloc/earnings_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'features/subscriptions/presentation/bloc/my_subscriptions_bloc.dart';
import 'core/utils/razorpay_checkout_helper.dart';
import 'core/services/payment_return_coordinator.dart';
import 'core/services/network_connectivity_service.dart';

void main() async {
  // Ensure Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set default config if not set (e.g., running main.dart directly)
  try {
    AppConfig.instance;
  } catch (_) {
    AppConfig.setConfiguration(AppConfig(
      environment: Environment.prod,
      baseUrl: 'https://api.am5royal.com/api/v1',
      appTitle: 'AM5 ROYAL',
    ));
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  // Initialize Push Notifications safely
  try {
    final pushService = PushNotificationService();
    await pushService.initialize();
    await pushService.getToken();
  } catch (e) {
    debugPrint("PushNotification init error: $e");
  }

  // Initialize Dependency Injection Service Locator
  try {
    await di.init();
    await RazorpayCheckoutHelper.initialize(
      onReturn: () => PaymentReturnCoordinator.onReturnFromUpi(appRouter),
    );
    NetworkConnectivityService().initialize();
  } catch (e) {
    debugPrint("DI/Razorpay init error: $e");
  }

  usePathUrlStrategy();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the ProductBloc and AuthBloc globally so CRUD/Auth actions can be invoked anywhere in the widget tree
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (_) => di.sl<ProductBloc>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
        BlocProvider<DeviceTrackingBloc>(
          create: (_) => di.sl<DeviceTrackingBloc>()..add(SyncDeviceEvent()),
        ),
        BlocProvider<EarningsBloc>(
          create: (_) => di.sl<EarningsBloc>(),
        ),
        BlocProvider<MySubscriptionsBloc>(
          create: (_) => di.sl<MySubscriptionsBloc>(),
        ),
        BlocProvider<OrdersBloc>(
          create: (_) => di.sl<OrdersBloc>(),
        ),
        BlocProvider<WalletBloc>(
          create: (_) => di.sl<WalletBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => di.sl<ProfileBloc>()..add(FetchProfileEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: AppConfig.instance.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Automatically matches light/dark settings of system
        routerConfig: appRouter,
        builder: (context, child) {
          if (AppConfig.instance.environment == Environment.dev) {
            return Banner(
              message: "DEV",
              location: BannerLocation.topEnd,
              color: Colors.red,
              child: child!,
            );
          }
          return child!;
        },
      ),
    );
  }
}
