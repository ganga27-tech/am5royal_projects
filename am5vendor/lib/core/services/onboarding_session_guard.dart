import 'package:shared_preferences/shared_preferences.dart';
import '../di/injection_container.dart' as di;

/// Controls whether vendor onboarding screens allow backward navigation.
///
/// - **Fresh session** (first open after OTP, app not killed): user can go back
///   and edit all steps until payment, once they move forward at least once.
/// - **Resume session** (app was closed and reopened before payment): user is
///   routed to their current step and cannot go back to edit previous steps.
class OnboardingSessionGuard {
  OnboardingSessionGuard._();
  static final OnboardingSessionGuard instance = OnboardingSessionGuard._();

  static const _prefsKey = 'onboarding_in_progress';

  bool _paymentCompleted = false;
  bool _isResumeSession = false;
  bool _allowBackNavigation = false;

  /// True when the user may navigate back to earlier onboarding steps.
  bool get canNavigateBack =>
      _paymentCompleted || (!_isResumeSession && _allowBackNavigation);

  /// Services can be changed any time before payment (including after app reopen).
  bool get canEditServices => !_paymentCompleted;

  bool get isResumeSession => _isResumeSession;

  /// Call once on cold start (splash / home redirect) before routing.
  Future<void> configureOnAppLaunch({
    required bool paymentCompleted,
    required bool onboardingIncomplete,
  }) async {
    if (paymentCompleted) {
      await markPaymentCompleted();
      return;
    }

    if (!onboardingIncomplete) return;

    final prefs = di.sl<SharedPreferences>();
    final wasInProgress = prefs.getBool(_prefsKey) ?? false;

    _paymentCompleted = false;
    _allowBackNavigation = false;
    _isResumeSession = wasInProgress;

    if (!wasInProgress) {
      await prefs.setBool(_prefsKey, true);
    }
  }

  /// Call when the user moves forward in onboarding during a fresh session.
  void unlockOnForwardProgress() {
    if (!_paymentCompleted && !_isResumeSession) {
      _allowBackNavigation = true;
    }
  }

  /// Force resume lock (e.g. home screen redirecting incomplete onboarding).
  void forceResumeSession() {
    if (!_paymentCompleted) {
      _isResumeSession = true;
      _allowBackNavigation = false;
    }
  }

  Future<void> markPaymentCompleted() async {
    _paymentCompleted = true;
    _isResumeSession = false;
    _allowBackNavigation = false;
    final prefs = di.sl<SharedPreferences>();
    await prefs.setBool(_prefsKey, false);
  }
}
