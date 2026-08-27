import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  Future<void> _sendEmail(BuildContext context, [String email = 'support@am5royal.com']) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'AM5ROYAL Terms & Conditions Inquiry'},
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open email app: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/water.png',
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.45),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Terms & Conditions',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkSurface.withValues(alpha: 0.8), AppColors.darkBackground]
                            : [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AM5 ROYAL Service Agreement',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Last updated: June 18, 2026',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDivider(context),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to AM5ROYAL! Please read these Terms of Service (“Terms”) carefully before using our website and application (collectively, the “Service”). By accessing or using the Service, you agree to be bound by these Terms.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          height: 1.65,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildParagraph(
                        context,
                        '1. Acceptance of Terms',
                        'By using AM5ROYAL, you agree to comply with and be legally bound by these Terms. If you do not agree to these Terms, do not use our Service.',
                      ),
                      _buildParagraph(
                        context,
                        '2. Eligibility',
                        'You must be at least 18 years old or have reached the age of majority in your jurisdiction to use the Service.',
                      ),
                      _buildParagraph(
                        context,
                        '3. User Accounts',
                        'You may be required to create an account to access certain features. You are responsible for maintaining the confidentiality of your account credentials and for all activities under your account.',
                      ),
                      _buildParagraph(
                        context,
                        '4. Use of the Service & Compliance Guidelines',
                        'You agree to use the Service in compliance with all applicable laws. Every vendor who registers on the platform undergoes a verification process to ensure a safe, reliable, and professional service experience. By registering, you agree to:\n• Provide accurate personal, business, and banking information.\n• Maintain professional conduct and deliver services with honesty, integrity, and respect.\n• Follow all applicable laws, regulations, and industry standards.\n• Protect customer privacy and maintain confidentiality.\n• Avoid fraudulent activities, misrepresentation, overcharging, harassment, or misconduct.',
                      ),
                      _buildParagraph(
                        context,
                        '5. Intellectual Property',
                        'All content, trademarks, logos, and other intellectual property on the Service are owned by AM5ROYAL or its licensors. You may not use, reproduce, or distribute any content without our written permission.',
                      ),
                      _buildParagraph(
                        context,
                        '6. Termination & Vendor Accountability',
                        'We reserve the right to suspend or terminate your access to the Service at our discretion. AM5ROYAL maintains a strict zero-tolerance policy toward fraudulent, unethical, or illegal activities. Any vendor engaging in misconduct, violating platform policies, damaging property, or abusing customers may face:\n• Immediate suspension or permanent termination of their vendor account.\n• Withholding of pending payments, where permitted by law and platform policies.\n• Reporting to relevant authorities for investigation.\n• Legal action, including civil or criminal proceedings, where applicable.',
                      ),
                      _buildParagraph(
                        context,
                        '7. Disclaimers',
                        'The Service is provided “as is” and “as available”. We make no warranties regarding the accuracy, reliability, or availability of the Service.',
                      ),
                      _buildParagraph(
                        context,
                        '8. Limitation of Liability',
                        'To the fullest extent permitted by law, AM5ROYAL and its affiliates shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the Service.',
                      ),
                      _buildParagraph(
                        context,
                        '9. Changes to Terms',
                        'We reserve the right to modify these Terms at any time. Changes will be effective immediately upon posting. Your continued use of the Service constitutes acceptance of the modified Terms.',
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '10. Contact Us',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'If you have any questions about these Terms, please contact us at ',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => _sendEmail(context, 'support@am5royal.com'),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.email_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'support@am5royal.com',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 60,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String title, String body) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              height: 1.65,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
