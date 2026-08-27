import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _sendEmail(BuildContext context, [String email = 'support@am5royal.com']) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'AM5ROYAL Privacy Policy Inquiry'},
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
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
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
                backgroundColor:
                    isDark ? AppColors.darkSurface : AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Privacy Policy',
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
                            ? [
                                AppColors.darkSurface.withValues(alpha: 0.8),
                                AppColors.darkBackground
                              ]
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeading(context, 'Privacy Policy'),
                      _buildBodyText(context, 'Effective Date: 1-March-2026'),
                      _buildHeading(context, 'Privacy Policy for AM5ROYAL'),
                      _buildBodyText(context,
                          'AM5ROYAL is the brand name of MSKGRC Private Limited, a B2B and B2C service marketplace that connects customers with verified service providers and vendors across India. We are committed to protecting your privacy and ensuring that your personal information is handled securely and responsibly.\nThis Privacy Policy explains how MSKGRC Private Limited ("Company", "We", "Us", or "Our") collects, uses, stores, shares, and protects your information when you use the AM5ROYAL website, mobile application, or any of our services.\nBy accessing or using AM5ROYAL, you agree to the practices described in this Privacy Policy.'),
                      _buildHeading(context, '1. Introduction'),
                      _buildBodyText(context,
                          'MSKGRC Private Limited owns and operates AM5ROYAL, a technology-driven service platform designed to connect customers with trusted service professionals and business vendors across multiple service categories.\nOur platform serves both:\n• B2C (Business to Customer): Customers can book services such as home cleaning, pest control, plumbing, electrical work, drivers, water purifier services, septic tank cleaning, and other professional services.\n• B2B (Business to Business): Vendors, service providers, agencies, and businesses can register, manage their profiles, receive qualified leads, grow their business, and connect with customers through the AM5ROYAL platform.\nProtecting your personal information is one of our highest priorities.'),
                      _buildHeading(context, '2. Policy Coverage'),
                      _buildBodyText(context,
                          'This Privacy Policy applies to all users of AM5ROYAL, including:\n• Customers\n• Vendors\n• Service Professionals\n• Business Partners\n• Visitors to our website\n• Mobile application users\n• Marketing campaign participants\n• Customer support interactions\nThe policy covers all personal information collected through:\n• Website\n• Mobile Application\n• Customer Support\n• Vendor Registration\n• Online Forms\n• Social Media Campaigns\n• Promotional Activities'),
                      _buildHeading(context, '3. Information We Collect'),
                      _buildBodyText(context,
                          'Depending on your interaction with AM5ROYAL, we may collect:\nPersonal Information\n• Full Name\n• Mobile Number\n• Email Address\n• Address\n• City and State\n• PIN Code\n• Profile Photo (optional)'),
                      _buildHeading(context, 'Vendor Information'),
                      _buildBodyText(context,
                          '• Business Name\n• GST Number (if applicable)\n• PAN Details (where required)\n• Aadhaar or Government-issued ID (for verification)\n• Bank Account Details (where required)\n• Business Address\n• Service Categories\n• Service Areas\n• Educational Qualifications\n• Professional Certifications\n• Trade License\n• Experience Certificate\n• Government-issued Registration Certificates\n• Skill Development Certificates\n• Business Licenses\nNote: Any other industry-specific qualification or certification required for the selected service category.'),
                      _buildHeading(context, 'Service Information'),
                      _buildBodyText(context,
                          '• Booking Details\n• Service Requests\n• Customer Reviews\n• Ratings\n• Communications\n• Payment Information\n• Transaction History'),
                      _buildHeading(context, 'Technical Information'),
                      _buildBodyText(context,
                          '• IP Address\n• Browser Type\n• Device Information\n• Cookies\n• Login Information\n• App Usage Data\n• Location Information (with your permission)'),
                      _buildHeading(context,
                          '4. Use of Information by MSKGRC Private Limited'),
                      _buildBodyText(context,
                          'We use the collected information to:\n• Provide our services efficiently\n• Connect customers with verified vendors\n• Process bookings and payments\n• Verify vendor identities\n• Improve service quality\n• Personalize user experience\n• Provide customer support\n• Send booking confirmations and notifications\n• Prevent fraud and misuse\n• Maintain platform security\n• Improve website and mobile application performance\n• Conduct internal analytics\n• Send promotional offers and updates (where permitted)\n• Comply with applicable legal and regulatory obligations\nWe use personal information only for legitimate business purposes and in accordance with applicable law.'),
                      _buildHeading(context,
                          '5. Visibility of Public Creative Contributions'),
                      _buildBodyText(context,
                          'Certain content submitted voluntarily by users may be publicly visible on the AM5ROYAL platform.\nThis may include:\n• Reviews\n• Ratings\n• Testimonials\n• Comments\n• Business Profiles\n• Vendor Portfolio Images\n• Service Descriptions\n• Promotional Content uploaded by vendors\nBy submitting such content, you grant MSKGRC Private Limited the right to display, reproduce, and publish the content on the AM5ROYAL platform and related marketing channels, unless otherwise agreed.\nUsers should avoid posting confidential or sensitive personal information in publicly visible areas.'),
                      _buildHeading(context,
                          '6. Sharing of Information with Third Parties'),
                      _buildBodyText(context,
                          'We do not sell your personal information.\nHowever, we may share information when necessary with:\n• Verified service providers\n• Registered vendors\n• Payment gateway providers\n• Banking partners\n• Technology service providers\n• Cloud hosting providers\n• Customer support partners\n• Marketing partners\n• Analytics providers\n• Government authorities when legally required\n• Law enforcement agencies when required by law\nThird parties are permitted to use the information only for authorized business purposes and are expected to maintain appropriate security and confidentiality measures.'),
                      _buildHeading(context, '7. Partnering with Others'),
                      _buildBodyText(context,
                          'AM5ROYAL may collaborate with:\n• Business partners\n• Service providers\n• Corporate clients\n• Franchise partners\n• Marketing agencies\n• Advertising partners\n• Technology partners\n• Financial institutions\n• Insurance partners\n• Government or public sector organizations\nThese partnerships help us improve our services and expand our offerings.\nWhere necessary, limited information may be shared to facilitate these partnerships. Such sharing will occur only for legitimate business purposes and in accordance with applicable privacy laws and contractual obligations.'),
                      _buildHeading(context, '8. Data Security'),
                      _buildBodyText(context,
                          'MSKGRC Private Limited implements appropriate administrative, technical, and physical safeguards to protect personal information against unauthorized access, loss, misuse, disclosure, alteration, or destruction.\nWhile we strive to use commercially reasonable means to protect your information, no method of transmission over the internet or electronic storage is completely secure.'),
                      _buildHeading(context, '9. Your Rights'),
                      _buildBodyText(context,
                          'Depending on applicable law, you may have the right to:\n• Access your personal information\n• Correct inaccurate information\n• Update your account details\n• Request deletion of personal information\n• Withdraw consent (where applicable)\n• Opt out of promotional communications\n• Request information about how your data is processed\nRequests may be subject to legal and operational requirements.'),
                      _buildHeading(context, '10. Cookies'),
                      _buildBodyText(context,
                          'AM5ROYAL may use cookies and similar technologies to improve user experience, remember preferences, analyze website traffic, and enhance platform performance.\nUsers may disable cookies through their browser settings, although some features may not function properly.'),
                      _buildHeading(
                          context, '11. Changes to this Privacy Policy'),
                      _buildBodyText(context,
                          'MSKGRC Private Limited reserves the right to update this Privacy Policy from time to time.\nAny changes will be published on our website and mobile application. Continued use of AM5ROYAL after changes become effective constitutes acceptance of the revised Privacy Policy.'),
                      _buildHeading(
                          context, 'Policy on Abuse of MSKGRC Private Limited'),
                      _buildBodyText(context,
                          'MSKGRC Private Limited, operating under the brand AM5ROYAL, is committed to maintaining a safe, secure, and trustworthy platform for customers, vendors, service professionals, and business partners.\nUsers must not misuse the AM5ROYAL platform by engaging in activities including, but not limited to:\n• Fraudulent or misleading service listings.\n• Impersonation of any person, business, or organization.\n• Uploading false, offensive, defamatory, abusive, or illegal content.\n• Attempting unauthorized access to user accounts or platform systems.\n• Distributing malware, viruses, or harmful software.\n• Using automated tools, bots, or scripts without written authorization.\n• Manipulating reviews, ratings, or customer feedback.\n• Harassing, threatening, or intimidating other users.\n• Violating applicable laws or regulations.\nMSKGRC Private Limited reserves the right to investigate suspected misuse and may suspend or permanently terminate accounts that violate these policies. Where appropriate, legal action may also be taken.'),
                      _buildHeading(context, 'Disclosures Required by Law'),
                      _buildBodyText(context,
                          'MSKGRC Private Limited may disclose personal or business information when required to:\n• Comply with applicable laws, regulations, or court orders.\n• Respond to lawful requests from government authorities or law enforcement agencies.\n• Protect the rights, property, safety, or security of MSKGRC Private Limited, AM5ROYAL, our users, employees, vendors, or the public.\n• Prevent fraud, cybercrime, security threats, or other illegal activities.\n• Enforce our Terms and Conditions or other contractual obligations.\nSuch disclosures will be limited to the information necessary to fulfill the legal requirement.'),
                      _buildHeading(context, 'Copyrighted Material'),
                      _buildBodyText(context,
                          'All content available on the AM5ROYAL platform, including but not limited to:\n• Logos\n• Brand names\n• Trademarks\n• Website design\n• Mobile application design\n• Images\n• Graphics\n• Icons\n• Videos\n• Text\n• Software\n• Databases\n• Marketing materials\nis owned by or licensed to MSKGRC Private Limited, unless otherwise stated, and is protected under applicable intellectual property laws.\nUsers may not copy, reproduce, distribute, modify, republish, or commercially exploit any content without prior written permission.\nIf you believe that your copyrighted work has been used on the AM5ROYAL platform without authorization, please contact us with sufficient details so that we can investigate and take appropriate action.'),
                      _buildHeading(context, 'Advertising and Spamming'),
                      _buildBodyText(context,
                          'Users are prohibited from using AM5ROYAL to:\n• Send unsolicited commercial messages.\n• Post spam, repetitive, or misleading content.\n• Promote unrelated businesses or competing services without authorization.\n• Send bulk promotional messages.\n• Harvest user information for marketing purposes.\n• Post malicious links or deceptive advertisements.\nOnly advertising or promotional activities expressly approved by MSKGRC Private Limited are permitted on the platform.\nViolation of this policy may result in content removal, account suspension, or permanent termination.'),
                      _buildHeading(context, 'Personal Information We Collect'),
                      _buildBodyText(context,
                          'To provide our services effectively, MSKGRC Private Limited may collect various categories of personal and business information, including:'),
                      _buildHeading(context, 'Personal Details'),
                      _buildBodyText(context,
                          '• Full Name\n• Mobile Number\n• Email Address\n• Residential or Business Address\n• City, State, and PIN Code\n• Profile Photograph (optional)\n• Date of Birth (where applicable)'),
                      _buildHeading(context, 'Vendor & Business Information'),
                      _buildBodyText(context,
                          '• Business Name\n• Business Registration Details\n• GST Number (where applicable)\n• PAN Number\n• Government-issued Identification for verification\n• Bank Account Details for settlements\n• Service Categories\n• Service Coverage Areas\n• Business Documents and Licenses (where required)'),
                      _buildHeading(
                          context, 'Booking & Transaction Information'),
                      _buildBodyText(context,
                          '• Service Requests\n• Booking History\n• Payment Details\n• Billing Information\n• Customer Reviews and Ratings\n• Vendor Performance Metrics\n• Customer Support Communications'),
                      _buildHeading(context, 'Device & Technical Information'),
                      _buildBodyText(context,
                          '• Device Type\n• Operating System\n• Browser Information\n• IP Address\n• Cookies\n• Login Activity\n• Location Information (with permission)\n• App Usage Analytics\n• Device Identifiers'),
                      _buildHeading(
                          context, 'Information Collected Automatically'),
                      _buildBodyText(context,
                          'When you use our website or mobile application, we may automatically collect certain technical information to improve performance, enhance security, analyze user behavior, personalize services, and maintain the overall functionality of the AM5ROYAL platform.\nWe collect only the information reasonably necessary to operate our services and comply with applicable legal and regulatory requirements.'),
                      _buildHeading(context, '12. Contact Us'),
                      _buildBodyText(context,
                          'If you have any questions, concerns, or requests regarding this Privacy Policy or your personal information, please contact:\nMSKGRC Private Limited\nBrand: AM5ROYAL'),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _sendEmail(context, 'support@am5royal.com'),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.email_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Email: support@am5royal.com',
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
                      const SizedBox(height: 4),
                      _buildBodyText(context,
                          'Website: www.vendor.am5royal.com\nCustomer Support: +91 99590 69035\nWe will make reasonable efforts to respond to your inquiry promptly.'),
                      const SizedBox(height: 40),
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

  Widget _buildHeading(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBodyText(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          height: 1.65,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
