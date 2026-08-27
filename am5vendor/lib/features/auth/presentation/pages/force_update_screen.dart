import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';

class ForceUpdateScreen extends StatefulWidget {
  final String currentVersion;
  final String requiredVersion;
  final String updateUrl;
  final String message;

  const ForceUpdateScreen({
    super.key,
    required this.currentVersion,
    required this.requiredVersion,
    required this.updateUrl,
    required this.message,
  });

  @override
  State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _btnController;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final Uri url = Uri.parse(widget.updateUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint("Could not launch $url");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open store. Please search for AM5 Royal Vendor in the store.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching update URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // 1. Brand linear gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkBackground,
                    Color(0xFF071F4D), // Dark royal blue blend
                    AppColors.darkBackground,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Subtle circular brand highlight in top corner
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withOpacity(0.12),
              ),
            ),
          ),

          // 2. Centered Content Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top Logo
                      Image.asset(
                        'assets/images/AM5 ROYAL TM logo.png',
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        'AM5 ROYAL',
                        style: GoogleFonts.outfit(
                          color: AppColors.accent, // Golden
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Premium Glassmorphic Card container
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            // Luxury Gold Alert Crown Ring Design
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent.withOpacity(0.1),
                                border: Border.all(
                                  color: AppColors.accent.withOpacity(0.3),
                                  width: 2.0,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.system_update_rounded,
                                  color: AppColors.accent,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Display/Headline - Track tight
                            Text(
                              'Upgrade Required',
                              style: GoogleFonts.outfit(
                                color: AppColors.darkTextPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Body description
                            Text(
                              widget.message.isNotEmpty
                                  ? widget.message
                                  : 'A critical update is available to keep your vendor app running smoothly. Please update to continue.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: AppColors.darkTextSecondary,
                                fontSize: 14.5,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Version status row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildVersionPill('Current', 'v${widget.currentVersion}', false),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.darkTextSecondary,
                                  size: 16,
                                ),
                                _buildVersionPill('Required', 'v${widget.requiredVersion}', true),
                              ],
                            ),
                            const SizedBox(height: 36),

                            // Custom Spring-Physics Interactive CTA Button
                            GestureDetector(
                              onTapDown: (_) => _btnController.forward(),
                              onTapUp: (_) {
                                _btnController.reverse();
                                _handleUpdate();
                              },
                              onTapCancel: () => _btnController.reverse(),
                              child: ScaleTransition(
                                scale: _btnScale,
                                child: Container(
                                  height: 56,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.accentGradient,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Update Now',
                                      style: GoogleFonts.outfit(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionPill(String label, String version, bool isRequired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isRequired
            ? AppColors.accent.withOpacity(0.12)
            : AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRequired
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.darkBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              color: isRequired ? AppColors.accent : AppColors.darkTextSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            version,
            style: GoogleFonts.outfit(
              color: AppColors.darkTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
