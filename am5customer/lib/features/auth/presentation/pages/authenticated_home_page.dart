import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/design_system/am5_colors.dart';

import '../bloc/auth_bloc.dart';
class AuthenticatedHomePage extends StatelessWidget {
  const AuthenticatedHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final unverified = user != null && !user.isEmailVerified;
        return LivoraScaffold(
          title: s.appName,
          actions: [
            IconButton(
              tooltip: s.profile,
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.person_outline),
            ),
            IconButton(
              tooltip: s.settings,
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LivoraLogo(size: 36),
              const SizedBox(height: 24),
              Text(
                '${s.homeGreeting}, ${user?.fullName ?? ''}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                s.moduleTwoReady,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              if (unverified) ...[
                const SizedBox(height: 16),
                Card(
                  color: Am5Colors.lightRed,
                  child: ListTile(
                    title: Text(s.profile),
                    subtitle: const Text('Verify your email'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      '/verify-email?email=${Uri.encodeComponent(user.email ?? '')}',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.manage_accounts_outlined),
                  title: Text(s.profile),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: Text(s.settings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
