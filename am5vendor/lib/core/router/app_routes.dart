/// Central route paths and names for the vendor app.
///
/// Always navigate with [AppRoutes] paths or [AppRouteNames] via go_router.
/// Category slugs under map use [mapCategoryPath] / [mapSubcategoryPath].
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const employeeLogin = '/employee-login';
  static const adminDashboard = '/admin-dashboard';
  static const marketingDashboard = '/marketing-dashboard';
  static const vendorAvailability = '/vendor-availability';
  static const partnerRegistration = '/partner-registration';
  static const vendorRegistration = partnerRegistration;
  static const businessRegistration = '/business-registration';
  static const home = '/home';
  static const map = '/map';
  static const productList = '/product-list';
  static const earnings = '/earnings';
  static const wallet = '/wallet';
  static const manageCategories = '/manage-categories';
  static const subscription = '/subscription';
  static const paymentProcessing = '/payment-processing';
  static const verificationPending = '/verification-pending';
  static const mySubscriptions = '/my-subscriptions';
  static const editProfile = '/edit-profile';
  static const vendorDashboard = '/vendor-dashboard';
  static const offersLaunches = '/offers-launches';
  static const ourStory = '/our-story';
  static const deleteAccount = '/delete-account';
  static const deleteAccountPolicy = '/delete-account-policy';
  static const verificationCertificate = '/verification-certificate';
  static const helpSupport = '/help-support';
  static const termsConditions = '/terms-conditions';
  static const privacyPolicy = '/privacypolicy';
  static const myEarnings = '/my-earnings';
  static const selectService = '/select-service';
  static const selectSubcategory = '/select-subcategory';
  static const forceUpdate = '/force-update';
  static const notFound = '/not-found';

  static String productDetail(String id) => '/product-detail/$id';
  static String orderDetails(int orderId) => '/orders/$orderId';
  static String mapCategory(String categorySlug) => '$map/$categorySlug';
  static String mapSubcategory(String categorySlug, String subcategorySlug) =>
      '${mapCategory(categorySlug)}/$subcategorySlug';
  static String categoryShortcut(String categorySlug) => '/$categorySlug';
  static String subcategoryShortcut(
    String categorySlug,
    String subcategorySlug,
  ) =>
      '/$categorySlug/$subcategorySlug';
}

abstract final class AppRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const employeeLogin = 'employee-login';
  static const adminDashboard = 'admin-dashboard';
  static const marketingDashboard = 'marketing-dashboard';
  static const vendorAvailability = 'vendor-availability';
  static const partnerRegistration = 'partner-registration';
  static const vendorRegistration = partnerRegistration;
  static const businessRegistration = 'business-registration';
  static const home = 'home';
  static const map = 'map';
  static const mapCategory = 'map-category';
  static const mapSubcategory = 'map-subcategory';
  static const productList = 'product-list';
  static const productDetail = 'product-detail';
  static const orderDetails = 'order-details';
  static const earnings = 'earnings';
  static const wallet = 'wallet';
  static const manageCategories = 'manage-categories';
  static const subscription = 'subscription';
  static const paymentProcessing = 'payment-processing';
  static const verificationPending = 'verification-pending';
  static const mySubscriptions = 'my-subscriptions';
  static const editProfile = 'edit-profile';
  static const vendorDashboard = 'vendor-dashboard';
  static const offersLaunches = 'offers-launches';
  static const ourStory = 'our-story';
  static const deleteAccount = 'delete-account';
  static const deleteAccountPolicy = 'delete-account-policy';
  static const verificationCertificate = 'verification-certificate';
  static const helpSupport = 'help-support';
  static const termsConditions = 'terms-conditions';
  static const privacyPolicy = 'privacypolicy';
  static const myEarnings = 'my-earnings';
  static const selectService = 'select-service';
  static const selectSubcategory = 'select-subcategory';
  static const forceUpdate = 'force-update';
  static const notFound = 'not-found';
  static const categoryShortcut = 'category-shortcut';
  static const subcategoryShortcut = 'subcategory-shortcut';
}

/// First path segments that must never be treated as category slugs.
const Set<String> kReservedRouteSegments = {
  'login',
  'employee-login',
  'admin-dashboard',
  'marketing-dashboard',
  'vendor-availability',
  'partner-registration',
  'vendor-registration',
  'business-registration',
  'home',
  'map',
  'product-list',
  'product-detail',
  'orders',
  'order-details',
  'earnings',
  'wallet',
  'manage-categories',
  'subscription',
  'payment-processing',
  'verification-pending',
  'my-subscriptions',
  'edit-profile',
  'vendor-dashboard',
  'offers-launches',
  'our-story',
  'delete-account',
  'delete-account-policy',
  'verification-certificate',
  'help-support',
  'terms-conditions',
  'terms-condition',
  'terms-and-conditions',
  'termsandconditions',
  'terms',
  'privacypolicy',
  'privacy-policy',
  'privacy',
  'my-earnings',
  'select-service',
  'select-subcategory',
  'force-update',
  'not-found',
};
