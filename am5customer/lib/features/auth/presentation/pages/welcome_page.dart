import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../../../../shared/widgets/app_primitives.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Am5Colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Am5Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(Am5Spacing.radiusMd),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: Am5Spacing.md),
                  Text(
                    'AM5 ROYAL',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Care that\ncomes home',
                style: theme.textTheme.headlineLarge?.copyWith(
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Am5Spacing.md),
              Text(
                'Book trusted home professionals for cleaning, beauty, repairs, and more.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Am5Colors.textSecondary,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Continue with OTP',
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: Am5Spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
