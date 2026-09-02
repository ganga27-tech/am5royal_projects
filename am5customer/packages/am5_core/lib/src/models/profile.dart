import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.preferredLocale,
    required this.roles,
    this.email,
    this.phone,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.gender,
    this.dateOfBirth,
    this.city,
    this.state,
    this.country,
  });

  final String userId;
  final String? email;
  final String? phone;
  final String fullName;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? gender;
  final String? dateOfBirth;
  final String? city;
  final String? state;
  final String? country;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String preferredLocale;
  final List<String> roles;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? true,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? true,
      preferredLocale: json['preferred_locale'] as String? ?? 'en',
      roles: (json['roles'] as List<dynamic>? ?? ['customer'])
          .map((e) => e.toString())
          .toList(),
    );
  }

  factory UserProfile.fromAm5CustomerProfile(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['id']?.toString() ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: (json['full_name'] as String?) ?? 'Customer',
      isEmailVerified: json['email'] != null,
      isPhoneVerified: json['phone'] != null,
      preferredLocale: 'en',
      roles: const ['customer'],
    );
  }

  String get name => displayName?.isNotEmpty == true ? displayName! : fullName;

  @override
  List<Object?> get props => [userId, fullName, displayName, preferredLocale, city];
}

class UserPreferences extends Equatable {
  const UserPreferences({
    required this.locale,
    required this.themeMode,
    required this.notificationsPush,
    required this.notificationsEmail,
    required this.notificationsSms,
    required this.marketingOptIn,
  });

  final String locale;
  final String themeMode; // system | light | dark
  final bool notificationsPush;
  final bool notificationsEmail;
  final bool notificationsSms;
  final bool marketingOptIn;

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      locale: json['locale'] as String? ?? 'en',
      themeMode: json['theme_mode'] as String? ?? 'system',
      notificationsPush: json['notifications_push'] as bool? ?? true,
      notificationsEmail: json['notifications_email'] as bool? ?? true,
      notificationsSms: json['notifications_sms'] as bool? ?? false,
      marketingOptIn: json['marketing_opt_in'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toPatchJson({
    String? locale,
    String? themeMode,
    bool? notificationsPush,
    bool? notificationsEmail,
    bool? notificationsSms,
    bool? marketingOptIn,
  }) {
    return {
      if (locale != null) 'locale': locale,
      if (themeMode != null) 'theme_mode': themeMode,
      if (notificationsPush != null) 'notifications_push': notificationsPush,
      if (notificationsEmail != null) 'notifications_email': notificationsEmail,
      if (notificationsSms != null) 'notifications_sms': notificationsSms,
      if (marketingOptIn != null) 'marketing_opt_in': marketingOptIn,
    };
  }

  UserPreferences copyWith({
    String? locale,
    String? themeMode,
    bool? notificationsPush,
    bool? notificationsEmail,
    bool? notificationsSms,
    bool? marketingOptIn,
  }) {
    return UserPreferences(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      notificationsPush: notificationsPush ?? this.notificationsPush,
      notificationsEmail: notificationsEmail ?? this.notificationsEmail,
      notificationsSms: notificationsSms ?? this.notificationsSms,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
    );
  }

  @override
  List<Object?> get props =>
      [locale, themeMode, notificationsPush, notificationsEmail, notificationsSms, marketingOptIn];
}
