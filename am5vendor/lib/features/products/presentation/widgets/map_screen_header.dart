import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/auth/domain/entities/auth.dart';

class MapScreenHeader extends StatelessWidget {
  final bool isMapView;
  final VoidCallback onToggleView;
  final bool isFloating;

  const MapScreenHeader({
    super.key,
    required this.isMapView,
    required this.onToggleView,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: isFloating
          ? EdgeInsets.zero
          : EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 8,
            ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E).withValues(alpha: isFloating ? 0.85 : 1.0)
            : Colors.white.withValues(alpha: isFloating ? 0.85 : 1.0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/AM5 ROYAL TM logo.png',
            height: 32,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.stars_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'AM5 Royal Vendor',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Toggle View: Maps vs Products Grid
          IconButton(
            icon: Icon(isMapView ? Icons.grid_view_rounded : Icons.map_rounded),
            tooltip: isMapView ? 'Show Grid View' : 'Show India Hubs Map',
            onPressed: onToggleView,
          ),
          // User Profile & Logout
          const _UserProfileMenu(),
        ],
      ),
    );
  }
}

class _UserProfileMenu extends StatefulWidget {
  const _UserProfileMenu();

  @override
  State<_UserProfileMenu> createState() => _UserProfileMenuState();
}

class _UserProfileMenuState extends State<_UserProfileMenu> {
  Auth? _currentUser;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content:
              const Text('Are you sure you want to log out of your session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthEvent.logout());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        state.maybeWhen(
          success: (_, auth) {
            _currentUser = auth;
          },
          orElse: () {},
        );

        final currentUser = _currentUser;
        if (currentUser == null) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: CircleAvatar(
            radius: 14,
            backgroundImage: currentUser.profilePhoto != null
                ? NetworkImage(currentUser.profilePhoto!)
                : null,
            backgroundColor: AppColors.primary,
            child: currentUser.profilePhoto == null
                ? Text(
                    currentUser.name != null && currentUser.name!.isNotEmpty
                        ? currentUser.name![0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          onSelected: (value) {
            if (value == 'logout') {
              _showLogoutDialog(context);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: currentUser.profilePhoto != null
                        ? NetworkImage(currentUser.profilePhoto!)
                        : null,
                    backgroundColor: AppColors.primary,
                    child: currentUser.profilePhoto == null
                        ? Text(
                            currentUser.name != null &&
                                    currentUser.name!.isNotEmpty
                                ? currentUser.name![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentUser.name ?? 'User',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        Text(
                          currentUser.contact,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
