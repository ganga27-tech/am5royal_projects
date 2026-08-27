import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Feature Page imports
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/employee_login_page.dart';
import '../../features/auth/presentation/pages/vendor_availability_page.dart';
import '../../features/auth/presentation/pages/force_update_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/home/presentation/pages/admin_dashboard_page.dart';
import '../../features/home/presentation/pages/telecaller_dashboard_page.dart';
import '../../features/home/presentation/pages/marketing_dashboard_page.dart';
import '../../features/home/presentation/pages/telecaller_vendor_onboard_page.dart';
import '../../features/products/presentation/pages/map_screen.dart';
import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/vendor_registration_page.dart';
import '../../features/products/presentation/pages/business_registration_page.dart';
import '../../features/products/presentation/pages/telecaller_vendor_services_update_page.dart';
import '../../features/orders/presentation/pages/order_details_screen.dart';
import '../../features/earnings/presentation/pages/earnings_screen.dart';
import '../../features/wallet/presentation/pages/wallet_screen.dart';
import '../../features/auth/presentation/pages/verification_pending_screen.dart';
import '../../features/subscriptions/presentation/pages/subscription_screen.dart';
import '../../features/vendor_catalog/presentation/pages/manage_category_screen.dart';
import '../../features/subscriptions/presentation/pages/my_subscriptions_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/profile/presentation/pages/delete_account_screen.dart';
import '../../features/profile/presentation/pages/delete_account_policy_screen.dart';
import '../../features/profile/presentation/pages/verification_certificate_screen.dart';
import '../../features/profile/presentation/pages/help_support_screen.dart';
import '../../features/profile/presentation/pages/terms_conditions_screen.dart';
import '../../features/profile/presentation/pages/privacy_policy_screen.dart';
import '../../features/profile/presentation/pages/my_earnings_screen.dart';
import '../../features/profile/presentation/pages/our_story_screen.dart';
import '../../features/dashboard/presentation/pages/vendor_dashboard_page.dart';
import '../../features/offers/presentation/pages/offers_launches_page.dart';
import '../../features/supercategory/presentation/pages/select_service_page.dart';
import '../../features/home/presentation/pages/telecaller_map_screen.dart';
import '../../features/home/presentation/pages/telecaller_select_service_page.dart';
import '../../features/home/data/models/telecaller_vendor_onboard_request_model.dart';

import '../../features/products/presentation/pages/select_subcategory_page.dart';

// Domain entity imports for params/extra mapping
import '../../features/orders/domain/entities/order_entity.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/supercategory/domain/entities/main_category.dart';
import '../../features/supercategory/domain/entities/subcategory_entity.dart';

import '../../core/services/analytics_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  observers: [
    AnalyticsService().analyticsObserver,
  ],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final fromLogout = state.uri.queryParameters['fromLogout'] == 'true';
        return LoginPage(fromLogout: fromLogout);
      },
    ),
    GoRoute(
      path: '/employee-login',
      builder: (context, state) => const EmployeeLoginPage(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/telecaller-dashboard',
      builder: (context, state) => const TelecallerDashboardPage(),
    ),
    GoRoute(
      path: '/telecaller/vendor-onboard',
      builder: (context, state) => const TelecallerVendorOnboardPage(),
    ),
    GoRoute(
      path: '/telecaller/map-screen',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final mobile = extra?['mobile'] as String? ?? '';
        final request = extra?['request'] as TelecallerVendorOnboardRequestModel?;
        return TelecallerMapScreen(
          mobile: mobile,
          request: request ?? TelecallerVendorOnboardRequestModel(
            firstName: '', lastName: '', fatherName: '', businessName: '',
            aadhaarNumber: '', address: '', city: '', state: '', pincode: '',
            serviceRadiusKm: 5, categories: [], services: []
          ),
        );
      },
    ),
    GoRoute(
      path: '/telecaller/select-service',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final mobile = extra?['mobile'] as String? ?? '';
        final request = extra?['request'] as TelecallerVendorOnboardRequestModel?;
        final mainCategory = extra?['mainCategory'] as MainCategory;
        final selectedSubCategories = extra?['selectedSubCategories'] as List<SubCategoryItem>? ?? [];
        final pendingCategory = extra?['pendingCategory'] as TelecallerCategoryRequest?;
        return TelecallerSelectServicePage(
          mobile: mobile,
          request: request ?? TelecallerVendorOnboardRequestModel(
            firstName: '', lastName: '', fatherName: '', businessName: '',
            aadhaarNumber: '', address: '', city: '', state: '', pincode: '',
            serviceRadiusKm: 5, categories: [], services: []
          ),
          mainCategory: mainCategory,
          selectedSubCategories: selectedSubCategories,
          pendingCategory: pendingCategory ?? TelecallerCategoryRequest(
            mainCategoryId: mainCategory.id.toString(),
            subCategoryIds: [],
          ),
        );
      },
    ),
    GoRoute(
      path: '/marketing-dashboard',
      builder: (context, state) => const MarketingDashboardPage(),
    ),
    GoRoute(
      path: '/vendor-availability',
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
        final isTelecallerOnboarded = extra?['isTelecallerOnboarded'] as bool? ?? false;
        final navigateToSubscriptionOnSave = extra?['navigateToSubscriptionOnSave'] as bool? ?? false;
        return VendorAvailabilityPage(
          mainCategoryId: mainCategoryId,
          mainCategoryName: mainCategoryName,
          selectedSubCategories: selectedSubCategories,
          selectedServiceTypes: selectedServiceTypes,
          firstName: firstName,
          lastName: lastName,
          businessName: businessName,
          isSingleService: isSingleService,
          isTelecallerOnboarded: isTelecallerOnboarded,
          navigateToSubscriptionOnSave: navigateToSubscriptionOnSave,
        );
      },
    ),
    GoRoute(
      path: '/telecaller-vendor-services-update',
      builder: (context, state) => const TelecallerVendorServicesUpdatePage(),
    ),
    GoRoute(
      path: '/vendor-registration',
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
        final isTelecallerOnboarded = extra?['isTelecallerOnboarded'] as bool? ?? false;
        return VendorRegistrationPage(
          mainCategoryId: mainCategoryId,
          mainCategoryName: mainCategoryName,
          selectedSubCategories: selectedSubCategories,
          selectedServiceTypes: selectedServiceTypes,
          isTelecallerOnboarded: isTelecallerOnboarded,
        );
      },
    ),
    GoRoute(
      path: '/business-registration',
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
      path: '/home',
      builder: (context, state) {
        final indexStr = state.uri.queryParameters['initialIndex'];
        final initialIndex = indexStr != null ? int.tryParse(indexStr) ?? 0 : 0;
        return HomeScreen(initialIndex: initialIndex);
      },
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/product-list',
      builder: (context, state) => const ProductListPage(),
    ),
    GoRoute(
      path: '/product-detail/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id'] ?? '';
        return ProductDetailPage(productId: productId);
      },
    ),
    GoRoute(
      path: '/order-details',
      builder: (context, state) {
        final order = state.extra as OrderEntity;
        return OrderDetailsScreen(order: order);
      },
    ),
    GoRoute(
      path: '/earnings',
      builder: (context, state) {
        final isEmbedded = state.uri.queryParameters['isEmbedded'] == 'true';
        return EarningsScreen(isEmbedded: isEmbedded);
      },
    ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: '/manage-categories',
      builder: (context, state) {
        final toPayment = state.uri.queryParameters['toPayment'] != '0';
        return ManageCategoryScreen(navigateToPaymentOnProceed: toPayment);
      },
    ),
    GoRoute(
      path: '/subscription',
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
      path: '/payment-processing',
      redirect: (context, state) => '/subscription?recover=1',
    ),
    GoRoute(
      path: '/verification-pending',
      builder: (context, state) => const VerificationPendingScreen(),
    ),
    GoRoute(
      path: '/my-subscriptions',
      builder: (context, state) {
        final isEmbedded = state.uri.queryParameters['isEmbedded'] == 'true';
        return MySubscriptionsScreen(isEmbedded: isEmbedded);
      },
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/vendor-dashboard',
      builder: (context, state) => const VendorDashboardPage(),
    ),
    GoRoute(
      path: '/offers-launches',
      builder: (context, state) => const OffersLaunchesPage(),
    ),
    GoRoute(
      path: '/our-story',
      builder: (context, state) => const OurStoryScreen(),
    ),
    GoRoute(
      path: '/delete-account',
      builder: (context, state) => const DeleteAccountScreen(),
    ),
    GoRoute(
      path: '/delete-account-policy',
      builder: (context, state) => const DeleteAccountPolicyScreen(),
    ),
    GoRoute(
      path: '/verification-certificate',
      builder: (context, state) => const VerificationCertificateScreen(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/terms-conditions',
      builder: (context, state) => const TermsConditionsScreen(),
    ),
    GoRoute(
      path: '/privacypolicy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/my-earnings',
      builder: (context, state) => const MyEarningsScreen(),
    ),
    GoRoute(
      path: '/select-service',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final mainCategory = extra?['mainCategory'] as MainCategory? ??
            const MainCategory(id: 0, name: 'Services', iconUrl: '', hasSubcategories: true);
        final selectedSubCategories =
            (extra?['selectedSubCategories'] as List<SubCategoryEntity>?) ?? const [];
        return SelectServicePage(
          mainCategory: mainCategory,
          selectedSubCategories: selectedSubCategories,
        );
      },
    ),
    GoRoute(
      path: '/select-subcategory',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final categoryId = extra?['categoryId'] as int? ?? 0;
        final superCategoryTitle = extra?['superCategoryTitle'] as String? ?? '';
        final mainCategory = extra?['mainCategory'] as MainCategory? ??
            const MainCategory(id: 0, name: 'Services', iconUrl: '', hasSubcategories: true);
        final isSingleService = extra?['isSingleService'] as bool? ?? true;
        final initialSelectedSubCategories =
            (extra?['initialSelectedSubCategories'] as List<SubCategoryItem>?) ?? const [];
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
      path: '/force-update',
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
  ],
);
