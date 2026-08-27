import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/dio_factory.dart';
import '../services/auth_storage_service.dart';
import '../services/payment_session_service.dart';
import '../network/auth_interceptor.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/create_product.dart';
import '../../features/products/domain/usecases/delete_product.dart';
import '../../features/products/domain/usecases/get_product.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/update_product.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_api_service.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_with_otp.dart';
import '../../features/auth/domain/usecases/login_with_google.dart';
import '../../features/auth/domain/usecases/check_session.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/delete_account.dart';
import '../../features/auth/domain/usecases/login_employee.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/vendor_availability_bloc.dart';
import '../../features/auth/presentation/bloc/business_registration_bloc/business_registration_bloc.dart';
import '../../features/supercategory/domain/usecases/upload_media_usecase.dart';
import '../../features/auth/domain/usecases/submit_business_details_usecase.dart';
import '../../features/supercategory/data/datasources/main_category_api_service.dart';
import '../../features/supercategory/domain/repositories/service_repository.dart';
import '../../features/supercategory/data/repositories/service_repository_impl.dart';

import '../../features/auth/data/datasources/vendor_availability_remote_data_source.dart';
import '../../features/auth/data/repositories/vendor_availability_repository_impl.dart';
import '../../features/auth/domain/repositories/vendor_availability_repository.dart';
import '../../features/auth/domain/usecases/get_vendor_availability.dart';
import '../../features/auth/domain/usecases/update_vendor_availability.dart';

import '../../features/device_tracking/data/datasources/device_tracking_local_data_source.dart';
import '../../features/device_tracking/data/datasources/device_tracking_remote_data_source.dart';
import '../../features/device_tracking/data/repositories/device_tracking_repository_impl.dart';
import '../../features/device_tracking/domain/repositories/device_tracking_repository.dart';
import '../../features/device_tracking/domain/usecases/sync_device_usecase.dart';
import '../../features/device_tracking/presentation/bloc/device_tracking_bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../features/subscriptions/data/datasources/subscription_remote_data_source.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository.dart';
import '../../features/subscriptions/domain/usecases/get_subscription_plans_usecase.dart';
import '../../features/subscriptions/domain/usecases/purchase_plan_usecase.dart';
import '../../features/subscriptions/domain/usecases/verify_payment_usecase.dart';
import '../../features/subscriptions/domain/usecases/recover_payment_usecase.dart';
import '../../features/subscriptions/domain/usecases/get_my_subscriptions_usecase.dart';
import '../../features/subscriptions/presentation/bloc/subscription_bloc.dart';
import '../../features/wallet/data/datasources/wallet_remote_data_source.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/get_wallet_details_usecase.dart';
import '../../features/wallet/domain/usecases/topup_wallet_usecase.dart';
import '../../features/wallet/domain/usecases/verify_topup_usecase.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';

import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_vendor_orders_usecase.dart';
import '../../features/orders/domain/usecases/start_service_usecase.dart';
import '../../features/orders/domain/usecases/complete_service_usecase.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';

import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/vendor_catalog/data/datasources/vendor_catalog_remote_data_source.dart';
import '../../features/vendor_catalog/data/repositories/vendor_catalog_repository.dart';
import '../../features/vendor_catalog/presentation/bloc/manage_catalog_bloc.dart';

import '../../features/earnings/data/datasources/earnings_remote_data_source.dart';
import '../../features/earnings/data/repositories/earnings_repository_impl.dart';
import '../../features/earnings/domain/repositories/earnings_repository.dart';
import '../../features/earnings/domain/usecases/get_my_earnings_usecase.dart';
import '../../features/earnings/presentation/bloc/earnings_bloc.dart';

import '../../features/subscriptions/presentation/bloc/my_subscriptions_bloc.dart';

import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/get_admin_stats.dart';
import '../../features/admin/domain/usecases/get_admin_employees.dart';
import '../../features/admin/domain/usecases/get_admin_vendors.dart';
import '../../features/admin/domain/usecases/update_employee_status.dart';
import '../../features/admin/domain/usecases/update_vendor_status.dart';
import '../../features/admin/domain/usecases/create_employee.dart';
import '../../features/admin/domain/usecases/update_employee.dart';
import '../../features/admin/domain/usecases/create_vendor.dart';
import '../../features/admin/domain/usecases/create_service.dart';
import '../../features/admin/domain/usecases/update_vendor.dart';
import '../../features/admin/domain/usecases/delete_vendor.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../../features/admin/presentation/bloc/admin_state.dart';
import '../../features/home/presentation/bloc/profile/employee_profile_bloc.dart';

import '../../features/marketing/data/datasources/marketing_remote_data_source.dart';
import '../../features/marketing/data/repositories/marketing_repository_impl.dart';
import '../../features/marketing/domain/repositories/marketing_repository.dart';
import '../../features/marketing/domain/usecases/create_lead.dart';
import '../../features/marketing/domain/usecases/get_leads.dart';
import '../../features/marketing/domain/usecases/get_collaterals.dart';
import '../../features/marketing/presentation/bloc/marketing_bloc.dart';
import '../../features/home/data/datasources/employee_api_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Marketing
  // Bloc
  sl.registerFactory(
    () => MarketingBloc(
      createLead: sl(),
      getLeads: sl(),
      getCollaterals: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateLead(sl()));
  sl.registerLazySingleton(() => GetLeads(sl()));
  sl.registerLazySingleton(() => GetCollaterals(sl()));

  // Repository
  sl.registerLazySingleton<MarketingRepository>(
    () => MarketingRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<MarketingRemoteDataSource>(
    () => MarketingRemoteDataSourceImpl(dio: sl()),
  );

  // Features - Orders
  sl.registerFactory(
    () => OrdersBloc(
      getVendorOrdersUseCase: sl(),
      startServiceUseCase: sl(),
      completeServiceUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetVendorOrdersUseCase(sl()));
  sl.registerLazySingleton(() => StartServiceUseCase(sl()));
  sl.registerLazySingleton(() => CompleteServiceUseCase(sl()));

  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(sl()),
  );

  // Features - Admin
  sl.registerFactory(
    () => AdminBloc(
      getAdminStats: sl(),
      getAdminEmployees: sl(),
      getAdminVendors: sl(),
      updateEmployeeStatus: sl(),
      updateVendorStatus: sl(),
      createEmployee: sl(),
      updateEmployee: sl(),
      createVendor: sl(),
      createService: sl(),
      updateVendor: sl(),
      deleteVendor: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetAdminStats(sl()));
  sl.registerLazySingleton(() => GetAdminEmployees(sl()));
  sl.registerLazySingleton(() => GetAdminVendors(sl()));
  sl.registerLazySingleton(() => UpdateEmployeeStatus(sl()));
  sl.registerLazySingleton(() => UpdateVendorStatus(sl()));
  sl.registerLazySingleton(() => CreateEmployee(sl()));
  sl.registerLazySingleton(() => UpdateEmployee(sl()));
  sl.registerLazySingleton(() => CreateVendor(sl()));
  sl.registerLazySingleton(() => CreateService(sl()));
  sl.registerLazySingleton(() => UpdateVendor(sl()));
  sl.registerLazySingleton(() => DeleteVendor(sl()));

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(dio: sl()),
  );

  // Features - Wallet
  // Bloc
  sl.registerFactory(
    () => WalletBloc(
      getWalletDetailsUseCase: sl(),
      topUpWalletUseCase: sl(),
      verifyTopupUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetWalletDetailsUseCase(sl()));
  sl.registerLazySingleton(() => TopUpWalletUseCase(sl()));
  sl.registerLazySingleton(() => VerifyTopupUseCase(sl()));

  // Repository
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(
      client: sl(),
    ),
  );
  // External (SharedPreferences & Dio)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => PaymentSessionService(sharedPreferences));
  
  // Storage Service
  final authStorageService = AuthStorageService(sharedPreferences);
  sl.registerLazySingleton(() => authStorageService);

  final dio = createConfiguredDio(
    authInterceptor: AuthInterceptor(authStorageService),
  );
  sl.registerLazySingleton(() => dio);

  // External Plugins
  sl.registerLazySingleton(() => DeviceInfoPlugin());

  // Blocs
  sl.registerFactory(
    () => ProductBloc(
      getProducts: sl(),
      getProduct: sl(),
      createProduct: sl(),
      updateProduct: sl(),
      deleteProduct: sl(),
    ),
  );
  sl.registerFactory(
    () => AuthBloc(
      loginWithOtp: sl(),
      loginWithGoogle: sl(),
      checkSession: sl(),
      logout: sl(),
      deleteAccount: sl(),
      loginEmployee: sl(),
    ),
  );
  sl.registerFactory(
    () => VendorAvailabilityBloc(
      getVendorAvailability: sl(),
      updateVendorAvailability: sl(),
    ),
  );
  sl.registerFactory(
    () => BusinessRegistrationBloc(
      uploadMediaUseCase: sl(),
      submitBusinessDetailsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => DeviceTrackingBloc(
      syncDeviceUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SubscriptionBloc(
      getSubscriptionPlans: sl(),
      purchasePlan: sl(),
      verifyPayment: sl(),
      recoverPayment: sl(),
      getMySubscriptions: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileBloc(
      repository: sl(),
    ),
  );
  sl.registerFactory(
    () => EarningsBloc(
      getMyEarningsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => MySubscriptionsBloc(
      getMySubscriptionsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => GetProduct(sl()));
  sl.registerLazySingleton(() => CreateProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));
  sl.registerLazySingleton(() => LoginWithOtp(sl()));
  sl.registerLazySingleton(() => LoginWithGoogle(sl()));
  sl.registerLazySingleton(() => CheckSession(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  sl.registerLazySingleton(() => LoginEmployee(sl()));
  sl.registerLazySingleton(() => UploadMediaUseCase(sl()));
  sl.registerLazySingleton(() => SubmitBusinessDetailsUseCase(sl()));
  
  sl.registerLazySingleton(() => GetVendorAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVendorAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => SyncDeviceUseCase(sl()));
  sl.registerLazySingleton(() => GetSubscriptionPlansUseCase(sl()));
  sl.registerLazySingleton(() => PurchasePlanUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPaymentUseCase(sl()));
  sl.registerLazySingleton(() => RecoverPaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetMyEarningsUseCase(sl()));
  sl.registerLazySingleton(() => GetMySubscriptionsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      authStorageService: sl(),
    ),
  );
  sl.registerLazySingleton<VendorAvailabilityRepository>(
    () => VendorAvailabilityRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DeviceTrackingRepository>(
    () => DeviceTrackingRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(sl()),
  );
  sl.registerLazySingleton<VendorCatalogRemoteDataSource>(
    () => VendorCatalogRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<VendorCatalogRepository>(
    () => VendorCatalogRepository(sl()),
  );
  sl.registerFactory(
    () => ManageCatalogBloc(repository: sl()),
  );
  sl.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(apiService: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => AuthApiService(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<VendorAvailabilityRemoteDataSource>(
    () => VendorAvailabilityRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DeviceTrackingRemoteDataSource>(
    () => DeviceTrackingRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DeviceTrackingLocalDataSource>(
    () => DeviceTrackingLocalDataSourceImpl(
      sharedPreferences: sl(),
      deviceInfoPlugin: sl(),
    ),
  );
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<EarningsRemoteDataSource>(
    () => EarningsRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton(() => MainCategoryApiService(sl()));
  sl.registerLazySingleton(() => EmployeeApiService(sl()));
  
  // Profile
  sl.registerFactory(() => EmployeeProfileBloc(employeeApiService: sl()));

  // Core
  sl.registerLazySingleton(() => ApiClient(sl()));
  
  // Eagerly resolve ApiClient to configure Dio options and interceptors immediately
  sl<ApiClient>();
}
