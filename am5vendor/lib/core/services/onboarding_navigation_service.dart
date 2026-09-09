import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/injection_container.dart' as di;
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import 'onboarding_session_guard.dart';
import 'payment_session_service.dart';
import '../router/app_routes.dart';

class OnboardingNavigationService {
  OnboardingNavigationService._();

  static bool isVerificationPending(String? status) {
    if (status == null || status.isEmpty) return false;
    final normalized = status.toLowerCase().replaceAll(' ', '_');
    return normalized == 'temporary_active';
  }

  static bool shouldShowVerificationPending({
    required bool subscription,
    required String? vendorStatus,
  }) {
    return subscription && isVerificationPending(vendorStatus);
  }

  static Future<Map<String, String>?> _loadCachedProfile() async {
    String firstName = 'Partner';
    String lastName = '';
    String businessName = 'Royal Partner';

    try {
      final authDataSource = di.sl<AuthLocalDataSource>();
      final authData = await authDataSource.getLastAuth();
      if (authData.name != null && authData.name!.isNotEmpty) {
        final parts = authData.name!.trim().split(' ');
        if (parts.isNotEmpty) {
          firstName = parts.first;
          if (parts.length > 1) {
            lastName = parts.sublist(1).join(' ');
          }
        }
      }
      businessName = '$firstName Services';
    } catch (_) {}

    return {
      'firstName': firstName,
      'lastName': lastName,
      'businessName': businessName,
    };
  }

  static Future<void> navigateFromStatusData(
    BuildContext context,
    Map<String, dynamic> data, {
    bool configureSession = true,
  }) async {
    if (!context.mounted) return;

    final bool otpVerified = data['otp_verified'] ?? false;
    final bool servicesAdded = data['services_added'] ?? false;
    final bool availabilityAdded = data['availability_added'] ?? false;
    final bool registrationDone = data['registration_done'] ?? false;
    final bool businessRegistrationDone =
        data['business_registration_done'] ?? false;
    final bool subscription = data['subscription'] ?? false;

    final profile = await _loadCachedProfile();
    final firstName = profile?['firstName'] ?? 'Partner';
    final lastName = profile?['lastName'] ?? '';
    final businessName = profile?['businessName'] ?? 'Royal Partner';
    const isSingleService = true;

    if (configureSession) {
      final onboardingIncomplete = !subscription &&
          (!servicesAdded ||
              !registrationDone ||
              !availabilityAdded ||
              !businessRegistrationDone);

      await OnboardingSessionGuard.instance.configureOnAppLaunch(
        paymentCompleted: subscription,
        onboardingIncomplete: onboardingIncomplete,
      );
    }

    if (!subscription) {
      await di.sl<PaymentSessionService>().clearSession();
      await di.sl<SharedPreferences>().remove('subscription_completed');
    }

    if (!context.mounted) return;

    if (!otpVerified) {
      context.go(AppRoutes.login);
      return;
    }

    if (!servicesAdded) {
      OnboardingSessionGuard.instance.forceResumeSession();
      context.go(AppRoutes.map);
      return;
    }

    if (!registrationDone) {
      OnboardingSessionGuard.instance.forceResumeSession();
      context.go(
        AppRoutes.vendorRegistration,
        extra: {
          'mainCategoryId': 1,
          'mainCategoryName': 'Services',
          'selectedSubCategories': const [],
          'selectedServiceTypes': const [],
        },
      );
      return;
    }

    if (!availabilityAdded) {
      OnboardingSessionGuard.instance.forceResumeSession();
      context.go(
        AppRoutes.vendorAvailability,
        extra: {
          'mainCategoryId': 1,
          'mainCategoryName': 'Home Services',
          'selectedSubCategories': const [],
          'selectedServiceTypes': const [],
          'firstName': firstName,
          'lastName': lastName,
          'businessName': businessName,
          'isSingleService': isSingleService,
        },
      );
      return;
    }

    if (!businessRegistrationDone) {
      OnboardingSessionGuard.instance.forceResumeSession();
      context.go(
        AppRoutes.businessRegistration,
        extra: {
          'firstName': firstName,
          'lastName': lastName,
          'businessName': businessName,
          'isSingleService': isSingleService,
        },
      );
      return;
    }

    if (!subscription) {
      OnboardingSessionGuard.instance.forceResumeSession();
      context.go(AppRoutes.subscription);
      return;
    }

    context.go(AppRoutes.home);
  }

  static Future<bool> fetchStatusAndNavigate(
    BuildContext context, {
    bool configureSession = true,
    bool fallbackToOnboardingStart = false,
  }) async {
    try {
      final dio = di.sl<Dio>();
      final response = await dio.get('/vendors/me/onboarding-status');
      if (response.statusCode != 200) return false;

      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is! Map<String, dynamic>) return false;

      if (!context.mounted) return false;
      await navigateFromStatusData(
        context,
        data,
        configureSession: configureSession,
      );
      return true;
    } on DioException catch (e) {
      debugPrint('Onboarding status sync failed: $e');
      if (fallbackToOnboardingStart && context.mounted) {
        await _navigateFallback(context);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Onboarding status sync failed: $e');
      if (fallbackToOnboardingStart && context.mounted) {
        await _navigateFallback(context);
        return true;
      }
      return false;
    }
  }

  static Future<void> _navigateFallback(BuildContext context) async {
    await OnboardingSessionGuard.instance.configureOnAppLaunch(
      paymentCompleted: false,
      onboardingIncomplete: true,
    );
    if (!context.mounted) return;
    context.go(AppRoutes.map);
  }
}
