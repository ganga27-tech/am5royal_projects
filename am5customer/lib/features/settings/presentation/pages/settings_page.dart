import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../cubit/preferences_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<PreferencesCubit, PreferencesViewState>(
      listenWhen: (p, c) => p.message != c.message,
      listener: (context, state) {
        if (state.message == null) return;
        final text = state.message == 'saved' ? s.saved : state.message!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
      },
      builder: (context, state) {
        final prefs = state.preferences;
        final saving = state.status == PreferencesStatus.saving;

        return Scaffold(
          backgroundColor: Am5Colors.background,
          appBar: AppBar(
            title: Text(s.settings),
            backgroundColor: Am5Colors.background,
            surfaceTintColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              LivoraSpacing.lg,
              LivoraSpacing.sm,
              LivoraSpacing.lg,
              LivoraSpacing.xxl,
            ),
            children: [
              _SectionCard(
                title: s.appearance,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.settingsAppearanceHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: LivoraSpacing.md),
                    SegmentedButton<String>(
                      style: _segmentStyle(theme),
                      segments: [
                        ButtonSegment(
                          value: 'system',
                          label: Text(s.themeSystem),
                          icon: const Icon(Icons.brightness_auto_outlined, size: 16),
                        ),
                        ButtonSegment(
                          value: 'light',
                          label: Text(s.themeLight),
                          icon: const Icon(Icons.light_mode_outlined, size: 16),
                        ),
                        ButtonSegment(
                          value: 'dark',
                          label: Text(s.themeDark),
                          icon: const Icon(Icons.dark_mode_outlined, size: 16),
                        ),
                      ],
                      selected: {prefs.themeMode},
                      onSelectionChanged: saving
                          ? null
                          : (v) => context
                              .read<PreferencesCubit>()
                              .setThemeMode(v.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LivoraSpacing.md),
              _SectionCard(
                title: s.language,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.settingsLanguageHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: LivoraSpacing.md),
                    SegmentedButton<String>(
                      style: _segmentStyle(theme),
                      segments: [
                        ButtonSegment(value: 'en', label: Text(s.english)),
                        ButtonSegment(value: 'hi', label: Text(s.hindi)),
                      ],
                      selected: {prefs.locale},
                      onSelectionChanged: saving
                          ? null
                          : (v) =>
                              context.read<PreferencesCubit>().setLocale(v.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LivoraSpacing.md),
              _SectionCard(
                title: s.notifications,
                child: Column(
                  children: [
                    _PrefSwitch(
                      icon: Icons.notifications_outlined,
                      title: s.pushNotifications,
                      value: prefs.notificationsPush,
                      enabled: !saving,
                      onChanged: (v) => context
                          .read<PreferencesCubit>()
                          .setNotification(push: v),
                    ),
                    const Divider(height: 1),
                    _PrefSwitch(
                      icon: Icons.mail_outline_rounded,
                      title: s.emailNotifications,
                      value: prefs.notificationsEmail,
                      enabled: !saving,
                      onChanged: (v) => context
                          .read<PreferencesCubit>()
                          .setNotification(email: v),
                    ),
                    const Divider(height: 1),
                    _PrefSwitch(
                      icon: Icons.sms_outlined,
                      title: s.smsNotifications,
                      value: prefs.notificationsSms,
                      enabled: !saving,
                      onChanged: (v) => context
                          .read<PreferencesCubit>()
                          .setNotification(sms: v),
                    ),
                    const Divider(height: 1),
                    _PrefSwitch(
                      icon: Icons.campaign_outlined,
                      title: s.marketing,
                      value: prefs.marketingOptIn,
                      enabled: !saving,
                      onChanged: (v) => context
                          .read<PreferencesCubit>()
                          .setNotification(marketing: v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LivoraSpacing.md),
              _SectionCard(
                title: s.security,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(const AuthLogoutRequested()),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(s.signOut),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: LivoraSpacing.sm),
                    TextButton(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(s.confirmDelete),
                            content: Text(s.deleteWarning),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(s.cancel),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: LivoraColors.error,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(s.deleteAccount),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          context.read<ProfileBloc>().add(const ProfileDeleted());
                        }
                      },
                      child: Text(
                        s.deleteAccount,
                        style: const TextStyle(color: LivoraColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              if (saving) ...[
                const SizedBox(height: LivoraSpacing.lg),
                const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  ButtonStyle _segmentStyle(ThemeData theme) {
    return ButtonStyle(
      visualDensity: VisualDensity.compact,
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return theme.colorScheme.onPrimary;
        }
        return theme.colorScheme.primary;
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return theme.colorScheme.primary;
        }
        return theme.colorScheme.surface;
      }),
      side: WidgetStatePropertyAll(
        BorderSide(color: theme.colorScheme.outlineVariant),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(LivoraSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _PrefSwitch extends StatelessWidget {
  const _PrefSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.titleSmall),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}


