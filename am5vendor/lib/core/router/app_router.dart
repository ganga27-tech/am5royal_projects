import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/employee_login_page.dart';
import '../../features/auth/presentation/pages/force_update_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/vendor_availability_page.dart';
import '../../features/auth/presentation/pages/verification_pending_screen.dart';
import '../../features/dashboard/presentation/pages/vendor_dashboard_page.dart';
import '../../features/earnings/presentation/pages/earnings_screen.dart';
import '../../features/home/presentation/pages/admin_dashboard_page.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/home/presentation/pages/marketing_dashboard_page.dart';
import '../../features/offers/presentation/pages/offers_launches_page.dart';
import '../../features/orders/domain/entities/order_entity.dart';
import '../../features/orders/presentation/pages/order_details_screen.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/products/presentation/pages/business_registration_page.dart';
import '../../features/products/presentation/pages/map_screen.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/presentation/pages/select_subcategory_page.dart';
import '../../features/products/presentation/pages/vendor_registration_page.dart';
import '../../features/profile/presentation/pages/delete_account_policy_screen.dart';
import '../../features/profile/presentation/pages/delete_account_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/profile/presentation/pages/help_support_screen.dart';
import '../../features/profile/presentation/pages/my_earnings_screen.dart';
import '../../features/profile/presentation/pages/our_story_screen.dart';
import '../../features/profile/presentation/pages/privacy_policy_screen.dart';
import '../../features/profile/presentation/pages/terms_conditions_screen.dart';
import '../../features/profile/presentation/pages/verification_certificate_screen.dart';
import '../../features/subscriptions/presentation/pages/my_subscriptions_screen.dart';
import '../../features/subscriptions/presentation/pages/subscription_screen.dart';
import '../../features/supercategory/domain/entities/main_category.dart';
import '../../features/supercategory/domain/entities/subcategory_entity.dart';
import '../../features/supercategory/presentation/pages/select_service_page.dart';
import '../../features/vendor_catalog/presentation/pages/manage_category_screen.dart';
import '../../features/wallet/presentation/pages/wallet_screen.dart';
import '../services/analytics_service.dart';
import 'app_routes.dart';
import 'category_route_pages.dart';
import 'not_found_page.dart';
import 'route_auth.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: kDebugMode,
  redirect: authRedirectGuard,
  errorBuilder: (context, state) => NotFoundPage(path: state.uri.path),
  observers: [
    AnalyticsService().analyticsObserver,
  ],
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRouteNames.login,
      builder: (context, state) {
        final fromLogout = state.uri.queryParameters['fromLogout'] == 'true';
        return LoginPage(fromLogout: fromLogout);
      },
    ),
    GoRoute(
      path: AppRoutes.employeeLogin,
      name: AppRouteNames.employeeLogin,
      builder: (context, state) => const EmployeeLoginPage(),
    ),
    GoRoute(
      path: AppRoutes.adminDashboard,
      name: AppRouteNames.adminDashboard,
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.marketingDashboard,
      name: AppRouteNames.marketingDashboard,
      builder: (context, state) => const MarketingDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.vendorAvailability,
      name: AppRouteNames.vendorAvailability,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final mainCategoryId = extra?['mainCategoryId'] as int? ?? 0;
        final mainCategoryName = extra?['mainCategoryName'] as String? ?? '';
        final selectedSubCategories =
            (extra?['selectedSubCategories'] as List?)?.cast<SubCategoryItem>() ??
                const [];
        final selectedServiceTypes =
            (extra?['selectedServiceTypes'] as List?)?.cast<SubSubCategoryItem>() ??
                const [];
        final firstName = extra?['firstName'] as String? ?? '';
        final lastName = extra?['lastName'] as String? ?? '';
        final businessName = extra?['businessName'] as String? ?? '';
        final isSingleService = extra?['isSingleService'] as bool? ?? true;
        final navigateToSubscriptionOnSave =
            extra?['navigateToSubscriptionOnSave'] as bool? ?? false;
        return VendorAvailabilityPage(
          mainCategoryId: mainCategoryId,
          mainCategoryName: mainCategoryName,
          selectedSubCategories: selectedSubCategories,
          selectedServiceTypes: selectedServiceTypes,
          firstName: firstName,
          lastName: lastName,
          businessName: businessName,
          isSingleService: isSingleService,
          navigateToSubscriptionOnSave: navigateToSubscriptionOnSave,
        );
      },
    ),
    GoRoute(
      path: '/vendor-registration',
      redirect: (context, state) => AppRoutes.partnerRegistration,
    ),
    GoRoute(
      path: AppRoutes.partnerRegistration,
      name: AppRouteNames.partnerRegistration,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final mainCategoryId = extra?['mainCategoryId'] as int? ?? 1;
        final mainCategoryName =
            extra?['mainCategoryName'] as String? ?? 'Home Services';
        final selectedSubCategories =
            (extra?['selectedSubCategories'] as List?)?.cast<SubCategoryItem>() ??
                const [];
        final selectedServiceTypes =
            (extra?['selectedServiceTypes'] as List?)?.cast<SubSubCategoryItem>() ??
                const [];
        return VendorRegistrationPage(
          mainCategoryId: mainCategoryId,
          mainCategoryName: mainCategoryName,
          selectedSubCategories: selectedSubCategories,
          selectedServiceTypes: selectedServiceTypes,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.businessRegistration,
      name: AppRouteNames.businessRegistration,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final firstName = extra?['firstName'] as String? ?? 'Partner';
        final lastName = extra?['lastName'] as String? ?? '';
        final businessName =
            extra?['businessName'] as String? ?? 'Royal Partner';
        final isSingleService = extra?['isSingleService'] as bool? ?? true;
        final mainCategoryId = extra?['mainCategoryId'] as int? ?? 1;
        final mainCategoryName =
            extra?['mainCategoryName'] as String? ?? 'Home Services';
        final selectedSubCategories =
            (extra?['selectedSubCategories'] as List?)?.cast<SubCategoryItem>() ??
                const [];
        final selectedServiceTypes =
            (extra?['selectedServiceTypes'] as List?)?.cast<SubSubCategoryItem>() ??
                const [];
        return BusinessRegistrationPage(
          firstName: firstName,
          lastName: lastName,
          businessName: businessName,
          isSingleService: isSingleService,
          mainCategoryId: mainCategoryId,
          mainCategoryName: mainCategoryName,
          selectedSubCategories: selectedSubCategories,
          selectedServiceTypes: selectedServiceTypes,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      name: AppRouteNames.home,
      builder: (context, state) {
        final indexStr = state.uri.queryParameters['initialIndex'];
        final initialIndex = indexStr != null ? int.tryParse(indexStr) ?? 0 : 0;
        return HomeScreen(initialIndex: initialIndex);
      },
    ),
    GoRoute(
      path: AppRoutes.map,
      name: AppRouteNames.map,
      builder: (context, state) => const MapScreen(),
      routes: [
        GoRoute(
          path: ':categorySlug',
          name: AppRouteNames.mapCategory,
          parentNavigatorKey: navigatorKey,
          builder: (context, state) {
            return CategoryRoutePage(
              categorySlug: state.pathParameters['categorySlug'] ?? '',
              extra: state.extra as Map<String, dynamic>?,
            );
          },
          routes: [
            GoRoute(
              path: ':subcategorySlug',
              name: AppRouteNames.mapSubcategory,
              parentNavigatorKey: navigatorKey,
              builder: (context, state) {
                return CategorySubcategoryRoutePage(
                  categorySlug: state.pathParameters['categorySlug'] ?? '',
                  subcategorySlug:
                      state.pathParameters['subcategorySlug'] ?? '',
                  extra: state.extra as Map<String, dynamic>?,
                );
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.productList,
      name: AppRouteNames.productList,
      builder: (context, state) => const ProductListPage(),
    ),
    GoRoute(
      path: '/product-detail/:id',
      name: AppRouteNames.productDetail,
      builder: (context, state) {
        final productId = state.pathParameters['id'] ?? '';
        return ProductDetailPage(productId: productId);
      },
    ),
    GoRoute(
      path: '/orders/:orderId',
      name: AppRouteNames.orderDetails,
      builder: (context, state) {
        final order = state.extra as OrderEntity?;
        if (order != null) {
          return OrderDetailsScreen(order: order);
        }
        final orderId =
            int.tryParse(state.pathParameters['orderId'] ?? '') ?? 0;
        return OrderDetailsScreen(
          order: OrderEntity(
            id: orderId,
            bookingReference: '#$orderId',
            status: 'pending',
          ),
        );
      },
    ),
    GoRoute(
      path: '/order-details',
      redirect: (context, state) {
        final order = state.extra as OrderEntity?;
        if (order != null) {
          return AppRoutes.orderDetails(order.id);
        }
        return AppRoutes.home;
      },
    ),
    GoRoute(
      path: AppRoutes.earnings,
      name: AppRouteNames.earnings,
      builder: (context, state) {
        final isEmbedded = state.uri.queryParameters['isEmbedded'] == 'true';
        return EarningsScreen(isEmbedded: isEmbedded);
      },
    ),
    GoRoute(
      path: AppRoutes.wallet,
      name: AppRouteNames.wallet,
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: AppRoutes.manageCategories,
      name: AppRouteNames.manageCategories,
      builder: (context, state) {
        final toPayment = state.uri.queryParameters['toPayment'] != '0';
        return ManageCategoryScreen(navigateToPaymentOnProceed: toPayment);
      },
    ),
    GoRoute(
      path: AppRoutes.subscription,
      name: AppRouteNames.subscription,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final fromOnboarding = extra?['fromOnboarding'] as bool? ?? false;
        final isSingleService = extra?['isSingleService'] as bool? ?? true;
        final selectedSubCategories =
            (extra?['selectedSubCategories'] as List?)?.cast<SubCategoryItem>() ??
                const [];
        final refreshKey =
            state.uri.queryParameters['r'] ?? 'subscription-default';
        final recoverPayment =
            state.uri.queryParameters['recover'] == '1';
        return SubscriptionScreen(
          key: ValueKey(refreshKey),
          fromOnboarding: fromOnboarding,
          recoverPayment: recoverPayment,
          isSingleService: isSingleService,
          selectedSubCategories: selectedSubCategories,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.paymentProcessing,
      name: AppRouteNames.paymentProcessing,
      redirect: (context, state) => '${AppRoutes.subscription}?recover=1',
    ),
    GoRoute(
      path: AppRoutes.verificationPending,
      name: AppRouteNames.verificationPending,
      builder: (context, state) => const VerificationPendingScreen(),
    ),
    GoRoute(
      path: AppRoutes.mySubscriptions,
      name: AppRouteNames.mySubscriptions,
      builder: (context, state) {
        final isEmbedded = state.uri.queryParameters['isEmbedded'] == 'true';
        return MySubscriptionsScreen(isEmbedded: isEmbedded);
      },
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      name: AppRouteNames.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.vendorDashboard,
      name: AppRouteNames.vendorDashboard,
      builder: (context, state) => const VendorDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.offersLaunches,
      name: AppRouteNames.offersLaunches,
      builder: (context, state) => const OffersLaunchesPage(),
    ),
    GoRoute(
      path: AppRoutes.ourStory,
      name: AppRouteNames.ourStory,
      builder: (context, state) => const OurStoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.deleteAccount,
      name: AppRouteNames.deleteAccount,
      builder: (context, state) => const DeleteAccountScreen(),
    ),
    GoRoute(
      path: AppRoutes.deleteAccountPolicy,
      name: AppRouteNames.deleteAccountPolicy,
      builder: (context, state) => const DeleteAccountPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.verificationCertificate,
      name: AppRouteNames.verificationCertificate,
      builder: (context, state) => const VerificationCertificateScreen(),
    ),
    GoRoute(
      path: AppRoutes.helpSupport,
      name: AppRouteNames.helpSupport,
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: AppRoutes.termsConditions,
      name: AppRouteNames.termsConditions,
      builder: (context, state) => const TermsConditionsScreen(),
    ),
    GoRoute(
      path: '/terms-condition',
      redirect: (context, state) => AppRoutes.termsConditions,
    ),
    GoRoute(
      path: '/terms-and-conditions',
      redirect: (context, state) => AppRoutes.termsConditions,
    ),
    GoRoute(
      path: '/termsandconditions',
      redirect: (context, state) => AppRoutes.termsConditions,
    ),
    GoRoute(
      path: '/terms',
      redirect: (context, state) => AppRoutes.termsConditions,
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      name: AppRouteNames.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      redirect: (context, state) => AppRoutes.privacyPolicy,
    ),
    GoRoute(
      path: '/privacy',
      redirect: (context, state) => AppRoutes.privacyPolicy,
    ),
    GoRoute(
      path: AppRoutes.myEarnings,
      name: AppRouteNames.myEarnings,
      builder: (context, state) => const MyEarningsScreen(),
    ),
    GoRoute(
      path: AppRoutes.selectService,
      name: AppRouteNames.selectService,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final mainCategory = extra?['mainCategory'] as MainCategory? ??
            const MainCategory(
              id: 0,
              name: 'Services',
              iconUrl: '',
              hasSubcategories: true,
            );
        final selectedSubCategories =
            (extra?['selectedSubCategories'] as List<SubCategoryEntity>?) ??
                const [];
        return SelectServicePage(
          mainCategory: mainCategory,
          selectedSubCategories: selectedSubCategories,
          isSingleService: extra?['isSingleService'] as bool? ?? true,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.selectSubcategory,
      name: AppRouteNames.selectSubcategory,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final categoryId = extra?['categoryId'] as int? ?? 0;
        final superCategoryTitle = extra?['superCategoryTitle'] as String? ?? '';
        final mainCategory = extra?['mainCategory'] as MainCategory? ??
            const MainCategory(
              id: 0,
              name: 'Services',
              iconUrl: '',
              hasSubcategories: true,
            );
        final isSingleService = extra?['isSingleService'] as bool? ?? true;
        final initialSelectedSubCategories =
            (extra?['initialSelectedSubCategories'] as List<SubCategoryItem>?) ??
                const [];
        return SelectSubcategoryPage(
          categoryId: categoryId,
          superCategoryTitle: superCategoryTitle,
          mainCategory: mainCategory,
          isSingleService: isSingleService,
          initialSelectedSubCategories: initialSelectedSubCategories,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.forceUpdate,
      name: AppRouteNames.forceUpdate,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final currentVersion = extra?['currentVersion'] as String? ?? '';
        final requiredVersion = extra?['requiredVersion'] as String? ?? '';
        final updateUrl = extra?['updateUrl'] as String? ?? '';
        final message = extra?['message'] as String? ?? '';
        return ForceUpdateScreen(
          currentVersion: currentVersion,
          requiredVersion: requiredVersion,
          updateUrl: updateUrl,
          message: message,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.notFound,
      name: AppRouteNames.notFound,
      builder: (context, state) => const NotFoundPage(),
    ),
    GoRoute(
      path: '/:categorySlug/:subcategorySlug',
      name: AppRouteNames.subcategoryShortcut,
      redirect: (context, state) {
        final categorySlug = state.pathParameters['categorySlug'] ?? '';
        final subcategorySlug = state.pathParameters['subcategorySlug'] ?? '';
        if (kReservedRouteSegments.contains(categorySlug)) {
          return AppRoutes.notFound;
        }
        return AppRoutes.mapSubcategory(categorySlug, subcategorySlug);
      },
    ),
    GoRoute(
      path: '/:categorySlug',
      name: AppRouteNames.categoryShortcut,
      redirect: (context, state) {
        final categorySlug = state.pathParameters['categorySlug'] ?? '';
        if (kReservedRouteSegments.contains(categorySlug)) {
          return AppRoutes.notFound;
        }
        return AppRoutes.mapCategory(categorySlug);
      },
    ),
  ],
);
