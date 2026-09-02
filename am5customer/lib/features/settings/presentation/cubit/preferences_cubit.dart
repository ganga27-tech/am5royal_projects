import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesCubit extends Cubit<PreferencesViewState> {
  PreferencesCubit({
    required SettingsApi settingsApi,
    required SharedPreferences prefs,
  })  : _settingsApi = settingsApi,
        _prefs = prefs,
        super(PreferencesViewState.initial(prefs));

  final SettingsApi _settingsApi;
  final SharedPreferences _prefs;

  static const _localeKey = 'livora_locale';
  static const _themeKey = 'livora_theme_mode';

  Future<void> hydrateFromServer() async {
    emit(state.copyWith(status: PreferencesStatus.loading));
    try {
      final remote = await _settingsApi.getPreferences();
      await _persistLocal(locale: remote.locale, themeMode: remote.themeMode);
      emit(
        state.copyWith(
          status: PreferencesStatus.ready,
          preferences: remote,
          clearMessage: true,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: PreferencesStatus.ready, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: PreferencesStatus.ready));
    }
  }

  Future<void> setThemeMode(String themeMode) async {
    await _applyPatch({'theme_mode': themeMode});
  }

  Future<void> setLocale(String locale) async {
    await _applyPatch({'locale': locale});
  }

  Future<void> setNotification({
    bool? push,
    bool? email,
    bool? sms,
    bool? marketing,
  }) async {
    await _applyPatch({
      if (push != null) 'notifications_push': push,
      if (email != null) 'notifications_email': email,
      if (sms != null) 'notifications_sms': sms,
      if (marketing != null) 'marketing_opt_in': marketing,
    });
  }

  Future<void> _applyPatch(Map<String, dynamic> patch) async {
    emit(state.copyWith(status: PreferencesStatus.saving, clearMessage: true));
    try {
      final remote = await _settingsApi.updatePreferences(patch);
      await _persistLocal(locale: remote.locale, themeMode: remote.themeMode);
      emit(
        state.copyWith(
          status: PreferencesStatus.ready,
          preferences: remote,
          message: 'saved',
        ),
      );
    } on Failure catch (f) {
      // Keep optimistic local change for theme/locale offline resilience
      if (patch.containsKey('theme_mode') || patch.containsKey('locale')) {
        final local = state.preferences.copyWith(
          themeMode: patch['theme_mode'] as String? ?? state.preferences.themeMode,
          locale: patch['locale'] as String? ?? state.preferences.locale,
        );
        await _persistLocal(locale: local.locale, themeMode: local.themeMode);
        emit(state.copyWith(status: PreferencesStatus.ready, preferences: local, message: f.message));
      } else {
        emit(state.copyWith(status: PreferencesStatus.ready, message: f.message));
      }
    }
  }

  Future<void> _persistLocal({required String locale, required String themeMode}) async {
    await _prefs.setString(_localeKey, locale);
    await _prefs.setString(_themeKey, themeMode);
  }
}

enum PreferencesStatus { initial, loading, saving, ready }

class PreferencesViewState extends Equatable {
  const PreferencesViewState({
    required this.status,
    required this.preferences,
    this.message,
  });

  factory PreferencesViewState.initial(SharedPreferences prefs) {
    final locale = prefs.getString('livora_locale') ?? 'en';
    final theme = prefs.getString('livora_theme_mode') ?? 'system';
    return PreferencesViewState(
      status: PreferencesStatus.initial,
      preferences: UserPreferences(
        locale: locale,
        themeMode: theme,
        notificationsPush: true,
        notificationsEmail: true,
        notificationsSms: false,
        marketingOptIn: false,
      ),
    );
  }

  final PreferencesStatus status;
  final UserPreferences preferences;
  final String? message;

  ThemeMode get materialThemeMode => switch (preferences.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Locale get materialLocale => Locale(preferences.locale);

  PreferencesViewState copyWith({
    PreferencesStatus? status,
    UserPreferences? preferences,
    String? message,
    bool clearMessage = false,
  }) {
    return PreferencesViewState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, preferences, message];
}
