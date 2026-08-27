import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

class VerificationCertificateScreen extends StatelessWidget {
  const VerificationCertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verification Certificate',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background watercolor mask matching onboarding theme
          Positioned.fill(
            child: Image.asset(
              'assets/images/water.png',
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.45),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      );
                    } else if (state is ProfileError) {
                      return Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.error, size: 44),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              style: GoogleFonts.outfit(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    } else if (state is ProfileLoaded) {
                      final profile = state.profile;
                      String displayName = "Authorized Partner";
                      if (profile.businessName != null &&
                          profile.businessName!.trim().isNotEmpty) {
                        displayName = profile.businessName!.trim();
                      } else if (profile.firstName != null ||
                          profile.lastName != null) {
                        displayName =
                            "${profile.firstName ?? ''} ${profile.lastName ?? ''}"
                                .trim();
                      }

                      return Column(
                        children: [
                          // Certificate image card with dynamic overlay name
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final cardWidth = constraints.maxWidth;
                                  // Certificate aspect ratio is 1062x801 -> height / width ~ 0.754
                                  final cardHeight = cardWidth * (801 / 1062);

                                  return SizedBox(
                                    height: cardHeight,
                                    width: cardWidth,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/certificate.jpg',
                                          fit: BoxFit.contain,
                                          width: cardWidth,
                                        ),
                                        // Position vendor name dynamically in the center space below "This certificate is proudly presented to" line
                                        Positioned(
                                          top: cardHeight * 0.40,
                                          left: cardWidth * 0.15,
                                          right: cardWidth * 0.15,
                                          child: Center(
                                            child: Text(
                                              displayName,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.cinzel(
                                                fontSize: (cardWidth * 0.048)
                                                    .clamp(13.0, 22.0),
                                                fontWeight: FontWeight.w900,
                                                color: const Color(0xFF0F2B48),
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
