import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config.dart';
import 'core/device.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/catalog/presentation/cubit/home_catalog_cubit.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';
import 'features/shop/presentation/cubit/cart_cubit.dart';
import 'features/shop/presentation/cubit/shop_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();

  late final AuthBloc authBloc;
  final apiClient = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    onSessionExpired: () => authBloc.add(const AuthSessionExpired()),
  );
  final authApi = AuthApi(apiClient);
  final profileApi = ProfileApi(apiClient);
  final settingsApi = SettingsApi(sharedPrefs);
  final catalogApi = CatalogApi(apiClient);
  final searchApi = SearchApi(apiClient);
  final addressApi = AddressApi(apiClient);
  final professionalsApi = ProfessionalsApi(apiClient);
  final bookingsApi = BookingsApi(apiClient);
  final paymentsApi = PaymentsApi(apiClient);
  final trackingApi = TrackingApi(apiClient);
  final commsApi = CommsApi(apiClient);
  final growthApi = GrowthApi(apiClient);
  final marketplaceApi = MarketplaceApi(apiClient);
  final device = await resolveDeviceInfo();
  authBloc = AuthBloc(authApi: authApi, device: device)..add(const AuthStarted());
  final preferencesCubit = PreferencesCubit(settingsApi: settingsApi, prefs: sharedPrefs);
  final profileBloc = ProfileBloc(profileApi: profileApi);
  final homeCatalogCubit = HomeCatalogCubit(catalogApi, searchApi, professionalsApi);
  final shopCubit = ShopCubit(marketplaceApi);
  final cartCubit = CartCubit(marketplaceApi);

  authBloc.stream.listen((state) {
    if (state.status == AuthStatus.authenticated) {
      preferencesCubit.hydrateFromServer();
      profileBloc.add(const ProfileStarted());
      homeCatalogCubit.load();
      shopCubit.load();
      cartCubit.load();
      commsApi
          .registerPushToken(
            token: 'dev-${device.deviceId}',
            platform: (device.platform ?? 'android').toLowerCase().contains('ios')
                ? 'ios'
                : 'android',
            deviceId: device.deviceId,
          )
          .catchError((_) => null);
    }
  });

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authApi),
        RepositoryProvider.value(value: profileApi),
        RepositoryProvider.value(value: settingsApi),
        RepositoryProvider.value(value: catalogApi),
        RepositoryProvider.value(value: searchApi),
        RepositoryProvider.value(value: addressApi),
        RepositoryProvider.value(value: professionalsApi),
        RepositoryProvider.value(value: bookingsApi),
        RepositoryProvider.value(value: paymentsApi),
        RepositoryProvider.value(value: trackingApi),
        RepositoryProvider.value(value: commsApi),
        RepositoryProvider.value(value: growthApi),
        RepositoryProvider.value(value: marketplaceApi),
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: device),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: preferencesCubit),
          BlocProvider.value(value: profileBloc),
          BlocProvider.value(value: homeCatalogCubit),
          BlocProvider.value(value: shopCubit),
          BlocProvider.value(value: cartCubit),
        ],
        child: const Am5CustomerApp(),
      ),
    ),
  );
}
