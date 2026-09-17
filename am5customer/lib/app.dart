import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import 'core/customer_theme.dart';
import 'core/auth/login_guard.dart';
import 'features/address/presentation/pages/address_form_page.dart';
import 'features/address/presentation/pages/address_list_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/bookings/presentation/pages/bookings_list_page.dart';
import 'features/bookings/presentation/pages/create_booking_page.dart';
import 'features/home/presentation/pages/premium_home_page.dart';
import 'features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import 'features/bookings/presentation/pages/booking_confirmation_page.dart';
import 'features/payments/presentation/pages/pay_booking_page.dart';
import 'features/payments/presentation/pages/wallet_page.dart';
import 'features/tracking/presentation/pages/live_tracking_page.dart';
import 'features/comms/presentation/pages/chat_page.dart';
import 'features/comms/presentation/pages/notifications_page.dart';
import 'features/growth/presentation/pages/support_page.dart';
import 'features/growth/presentation/pages/membership_page.dart';
import 'features/growth/presentation/pages/referral_page.dart';
import 'features/growth/presentation/pages/invoices_page.dart';
import 'features/catalog/presentation/pages/category_detail_page.dart';
import 'features/catalog/presentation/pages/service_detail_page.dart';
import 'features/professionals/presentation/pages/professionals_list_page.dart';
import 'features/professionals/presentation/pages/vendor_detail_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/search/presentation/pages/search_page.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/shop/presentation/pages/cart_page.dart';
import 'features/shop/presentation/pages/product_detail_page.dart';
import 'features/shop/presentation/pages/product_orders_page.dart';
import 'features/shop/presentation/pages/shop_page.dart';
import 'features/shell/customer_shell.dart';

class Am5CustomerApp extends StatefulWidget {
  const Am5CustomerApp({super.key});

  @override
  State<Am5CustomerApp> createState() => _Am5CustomerAppState();
}

class _Am5CustomerAppState extends State<Am5CustomerApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: _AuthRefresh(context.read<AuthBloc>()),
      redirect: (context, state) {
        final auth = context.read<AuthBloc>().state;
        return resolveAppRedirect(
          authStatus: auth.status,
          location: state.matchedLocation,
          redirectQueryParam: state.uri.queryParameters['redirect'],
        );
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomePage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              LoginPage(redirectTo: state.uri.queryParameters['redirect']),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) => OtpPage(
            destination: state.uri.queryParameters['to'] ?? '',
            redirectTo: state.uri.queryParameters['redirect'],
          ),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              CustomerShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const PremiumHomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (context, state) =>
                      SearchPage(initialQuery: state.uri.queryParameters['q']),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/assistant',
                  builder: (context, state) => const AiAssistantPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/bookings',
                  builder: (context, state) => const BookingsListPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfilePage(),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => const EditProfilePage(),
                    ),
                    GoRoute(
                      path: 'addresses',
                      builder: (context, state) => const AddressListPage(),
                      routes: [
                        GoRoute(
                          path: 'new',
                          builder: (context, state) => const AddressFormPage(),
                        ),
                        GoRoute(
                          path: ':id/edit',
                          builder: (context, state) => AddressFormPage(
                            addressId: state.pathParameters['id'],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/categories/:id',
          builder: (context, state) =>
              CategoryDetailPage(categoryId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/services/:id',
          builder: (context, state) =>
              ServiceDetailPage(serviceId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/professionals',
          builder: (context, state) => ProfessionalsListPage(
            serviceId: state.uri.queryParameters['service_id'],
            city: state.uri.queryParameters['city'],
          ),
        ),
        GoRoute(
          path: '/professionals/:id',
          builder: (context, state) =>
              VendorDetailPage(vendorId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/vendors/:id',
          builder: (context, state) =>
              VendorDetailPage(vendorId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/bookings/:id/pay',
          builder: (context, state) =>
              PayBookingPage(bookingId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/bookings/:id/track',
          builder: (context, state) =>
              LiveTrackingPage(bookingId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/bookings/:id/chat',
          builder: (context, state) =>
              ChatPage(bookingId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/wallet',
          builder: (context, state) => const WalletPage(),
        ),
        GoRoute(
          path: '/membership',
          builder: (context, state) => const MembershipPage(),
        ),
        GoRoute(
          path: '/support',
          builder: (context, state) => const SupportPage(),
        ),
        GoRoute(
          path: '/referral',
          builder: (context, state) => const ReferralPage(),
        ),
        GoRoute(
          path: '/invoices',
          builder: (context, state) => const InvoicesPage(),
        ),
        GoRoute(
          path: '/addresses/new',
          builder: (context, state) => const AddressFormPage(),
        ),
        GoRoute(
          path: '/addresses/:id/edit',
          builder: (context, state) =>
              AddressFormPage(addressId: state.pathParameters['id']),
        ),
        GoRoute(
          path: '/book',
          builder: (context, state) {
            final q = state.uri.queryParameters;
            return CreateBookingPage(
              professionalId: q['professional_id'] ?? '',
              serviceId: q['service_id'] ?? '',
              professionalName: q['professional_name'] ?? '',
              serviceName: q['service_name'] ?? '',
            );
          },
        ),
        GoRoute(path: '/shop', builder: (context, state) => const ShopPage()),
        GoRoute(
          path: '/booking-confirmed',
          builder: (context, state) =>
              BookingConfirmationPage(booking: state.extra as Booking),
        ),
        GoRoute(
          path: '/shop/products/:id',
          builder: (context, state) =>
              ProductDetailPage(productId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/shop/cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: '/shop/orders',
          builder: (context, state) => const ProductOrdersPage(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesCubit, PreferencesViewState>(
      builder: (context, prefsState) {
        return MaterialApp.router(
          title: 'AM5 Royal',
          debugShowCheckedModeBanner: false,
          theme: CustomerTheme.light(),
          darkTheme: CustomerTheme.dark(),
          themeMode: prefsState.materialThemeMode,
          locale: prefsState.materialLocale,
          supportedLocales: const [Locale('en'), Locale('hi')],
          localizationsDelegates: const [
            LivoraStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
        );
      },
    );
  }
}

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._bloc) : _lastStatus = _bloc.state.status {
    _subscription = _bloc.stream.listen((next) {
      if (next.status == _lastStatus) return;
      _lastStatus = next.status;
      notifyListeners();
    });
  }

  final AuthBloc _bloc;
  AuthStatus _lastStatus;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
