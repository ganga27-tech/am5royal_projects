import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get analyticsObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Set User ID after login
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('Analytics setUserId error: $e');
    }
  }

  /// Set User Properties (e.g. city, user_role)
  Future<void> setUserProperty({required String name, required String? value}) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics setUserProperty error: $e');
    }
  }

  /// Log custom events
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('Logged Analytics Event: $name params: $parameters');
    } catch (e) {
      debugPrint('Analytics logEvent error: $e');
    }
  }

  /// Log User Sign-Up
  Future<void> logSignUp({required String signUpMethod}) async {
    try {
      await _analytics.logSignUp(signUpMethod: signUpMethod);
    } catch (e) {
      debugPrint('Analytics logSignUp error: $e');
    }
  }

  /// Log User Login
  Future<void> logLogin({required String loginMethod}) async {
    try {
      await _analytics.logLogin(loginMethod: loginMethod);
    } catch (e) {
      debugPrint('Analytics logLogin error: $e');
    }
  }

  /// Log Subscription / Purchase Event
  Future<void> logSubscriptionPurchase({
    required String planName,
    required double amount,
    required String currency,
  }) async {
    try {
      await _analytics.logPurchase(
        currency: currency,
        value: amount,
        items: [
          AnalyticsEventItem(
            itemName: planName,
            itemCategory: 'SubscriptionPlan',
            price: amount,
          )
        ],
      );
    } catch (e) {
      debugPrint('Analytics logPurchase error: $e');
    }
  }
}
