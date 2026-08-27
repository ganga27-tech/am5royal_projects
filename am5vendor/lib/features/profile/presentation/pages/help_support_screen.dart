import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';
import '../../../../features/home/presentation/pages/home_screen.dart'; // import SpringButton

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _supportPhone = '9948605987';
  static const String _displayPhone = '+91 99486 05987';

  Future<void> _makeCall(BuildContext context) async {
    final Uri uri = Uri(scheme: 'tel', path: '+91$_supportPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not initiate call: $e')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final Uri whatsappUri =
        Uri.parse('https://wa.me/91$_supportPhone?text=Hello%20AM5ROYAL%20Support');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        final fallbackUri =
            Uri.parse('https://api.whatsapp.com/send?phone=91$_supportPhone');
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp: $e')),
        );
      }
    }
  }

  Future<void> _sendEmail(BuildContext context, [String email = 'support@am5royal.com']) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'AM5ROYAL Vendor Support'},
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
                    'Help & Support',
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Support',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Contact Options Grid
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildContactCard(
                                  context: context,
                                  icon: Icons.phone_in_talk_rounded,
                                  label: 'Call Us',
                                  sub: _displayPhone,
                                  color: Colors.blue,
                                  onTap: () => _makeCall(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildContactCard(
                                  context: context,
                                  icon: Icons.chat_bubble_rounded,
                                  label: 'WhatsApp',
                                  sub: _displayPhone,
                                  color: Colors.green,
                                  onTap: () => _openWhatsApp(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildContactCard(
                            context: context,
                            icon: Icons.email_rounded,
                            label: 'Email Us',
                            sub: 'support@am5royal.com',
                            color: Colors.deepOrange,
                            onTap: () => _sendEmail(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      Text(
                        'Frequently Asked Questions',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildFaqTile(
                        context: context,
                        question: 'How Do I Become an AM5 ROYAL Vendor?',
                        answer: 'Step 1: Create your account using your mobile number and provide your basic business details.\nStep 2: Upload the required documents, including your Aadhaar Card, PAN Card, passport-size photograph, and relevant service certifications.\nStep 3: Complete the profile verification process. Once your profile has been reviewed and approved by our Verification Department, your vendor account will be activated.',
                      ),
                      _buildFaqTile(
                        context: context,
                        question: 'What Documents Are Required to Join?',
                        answer: 'To join AM5 ROYAL as a vendor, you need to provide the following documents:\n• Aadhaar Card: For identity verification.\n• PAN Card: For business, tax, and financial verification.\n• Passport-Size Photograph: For your professional profile.\n• Service-Related Certifications/Licenses: If applicable to your service.',
                      ),
                      _buildFaqTile(
                        context: context,
                        question: 'Can I Cancel My Premium Subscription?',
                        answer: 'Once you subscribe to the premium package, the subscription cannot be cancelled, and the fee is non-refundable. The subscription grants access to exclusive leads and platform services for the chosen subscription period.',
                      ),
                      _buildFaqTile(
                        context: context,
                        question: 'How Does Number Masking Work?',
                        answer: 'For privacy and security, the customer\'s and vendor\'s phone numbers are masked. Calls between customers and vendors are securely connected through our automated IVR system, ensuring that neither party\'s actual phone number is revealed.',
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

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SpringButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface.withValues(alpha: 0.9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        collapsedIconColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        iconColor: AppColors.accent,
        shape: const Border(),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              answer,
              style: GoogleFonts.outfit(
                fontSize: 12,
                height: 1.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
