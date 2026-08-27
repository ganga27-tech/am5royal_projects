import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/constants/colors.dart';
import '../../../../core/services/auth_storage_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class MarketingDashboardPage extends StatefulWidget {
  const MarketingDashboardPage({super.key});

  @override
  State<MarketingDashboardPage> createState() => _MarketingDashboardPageState();
}

class _MarketingDashboardPageState extends State<MarketingDashboardPage> {
  int _activeMenuIndex = 0;
  bool _isHoveredLogout = false;

  // Form State
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String _selectedCategory = 'Home Cleaning';

  // Geolocator/GPS State
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  bool _useMockGps = true; // Enabled by default to ensure success in web/simulators

  // Image Picker State
  XFile? _shopFrontPhoto;
  XFile? _ownerPhoto;
  XFile? _aadhaarPhoto;
  XFile? _gstPhoto;

  final ImagePicker _picker = ImagePicker();

  // Local Mock Lists
  final List<Map<String, dynamic>> _assignedLeads = [
    {'id': 'ml1', 'shopName': 'Royal Hair Salon', 'address': 'Madhapur Road, Sec-2', 'status': 'Pending Visit', 'contact': '+91 9900881122'},
    {'id': 'ml2', 'shopName': 'Krishna Sweets & Bakery', 'address': 'Hitech City Lane 3', 'status': 'Visited & Onboarded', 'contact': '+91 8800772233'},
    {'id': 'ml3', 'shopName': 'Home Comforts Furniture', 'address': 'Kondapur Main Rd', 'status': 'Call Back Later', 'contact': '+91 7700663344'},
    {'id': 'ml4', 'shopName': 'Sri Sai Electronics', 'address': 'Gachibowli Ring Road', 'status': 'Pending Visit', 'contact': '+91 6600554455'},
  ];

  final List<Map<String, dynamic>> _performanceHistory = [
    {'date': '2026-06-19', 'shop': 'Krishna Sweets', 'points': 50, 'status': 'Verified'},
    {'date': '2026-06-17', 'shop': 'Perfect Plumbing Depot', 'points': 50, 'status': 'Verified'},
    {'date': '2026-06-16', 'shop': 'Superb AC Hub', 'points': 50, 'status': 'Pending Approval'},
  ];

  final List<String> _categoriesList = [
    'Home Cleaning',
    'Plumbing',
    'AC & Appliance Repair',
    'Electrical Services',
    'Salon & Beauty',
    'Painting',
  ];

  int _totalReferralPoints = 720;
  int _dailyVisitsCount = 3;
  final int _dailyVisitsTarget = 8;
  bool _isPlayingCollateralVideo = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  // --- GPS GETTER ---
  Future<void> _fetchGPSLocation() async {
    setState(() => _isLocating = true);
    
    if (_useMockGps) {
      // Simulate real delay
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      setState(() {
        _latitude = 17.4483 + (0.005 * (DateTime.now().second % 5));
        _longitude = 78.3741 - (0.003 * (DateTime.now().second % 3));
        _isLocating = false;
      });
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLocating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLocating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS error: $e. Falling back to Mock GPS.'),
          backgroundColor: Colors.amber[800],
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ),
      );
      // Auto-trigger mock on failure
      setState(() {
        _latitude = 17.4483;
        _longitude = 78.3741;
      });
    }
  }

  // --- CAMERA CAPTURE ---
  Future<void> _capturePhoto(String photoType) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60,
      );
      if (!mounted) return;
      if (photo != null) {
        setState(() {
          if (photoType == 'shop') _shopFrontPhoto = photo;
          if (photoType == 'owner') _ownerPhoto = photo;
          if (photoType == 'aadhaar') _aadhaarPhoto = photo;
          if (photoType == 'gst') _gstPhoto = photo;
        });
      }
    } catch (e) {
      // If camera fails (web/simulator sandbox), fallback to picking image file
      try {
        final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
        if (!mounted) return;
        if (photo != null) {
          setState(() {
            if (photoType == 'shop') _shopFrontPhoto = photo;
            if (photoType == 'owner') _ownerPhoto = photo;
            if (photoType == 'aadhaar') _aadhaarPhoto = photo;
            if (photoType == 'gst') _gstPhoto = photo;
          });
        }
      } catch (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera picker error: $err')),
        );
      }
    }
  }

  // --- SUBMIT REGISTRATION ---
  void _submitOnSpotOnboarding() {
    final shopName = _shopNameController.text.trim();
    final ownerName = _ownerNameController.text.trim();
    final contact = _contactController.text.trim();

    if (shopName.isEmpty || ownerName.isEmpty || contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Shop, Owner and Contact details.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture the GPS coordinates of the shop.'), backgroundColor: Colors.amber),
      );
      return;
    }

    // On-spot F2F onboarding awards 50 points
    setState(() {
      _performanceHistory.insert(0, {
        'date': '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
        'shop': shopName,
        'points': 50,
        'status': 'Pending Approval',
      });
      _totalReferralPoints += 50;
      _dailyVisitsCount += 1;
    });

    _shopNameController.clear();
    _ownerNameController.clear();
    _contactController.clear();
    setState(() {
      _latitude = null;
      _longitude = null;
      _shopFrontPhoto = null;
      _ownerPhoto = null;
      _aadhaarPhoto = null;
      _gstPhoto = null;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Icon(Icons.stars, color: Color(0xFFD4A33A), size: 52),
            const SizedBox(height: 12),
            Text('Success! +50 Points', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF0C3D98))),
          ],
        ),
        content: Text(
          'Vendor "$shopName" has been registered on the spot. Referral points have been loaded into your pending balance.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C3D98),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Done', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authStorage = di.sl<AuthStorageService>();
    final token = authStorage.getAccessToken() ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            initial: () => context.go('/login'),
            orElse: () {},
          );
        },
        child: Stack(
          children: [
            // Watercolor background
            Positioned.fill(
              child: Image.asset(
                'assets/images/water.png',
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(isDark ? 0.25 : 0.8),
              ),
            ),

            // Color blend overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.darkBackground.withValues(alpha: 0.8),
                            AppColors.darkBackground.withValues(alpha: 0.6),
                            AppColors.darkBackground.withValues(alpha: 0.9),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.55),
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Main body
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar
                    _buildTopBar(context, isDark, token),
                    const SizedBox(height: 20),

                    // Content Layout
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sidebar
                          if (MediaQuery.of(context).size.width > 800) ...[
                            _buildSidebar(context, isDark),
                            const SizedBox(width: 20),
                          ],

                          // Main View Container
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.35)
                                    : Colors.white.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: _buildActiveTabContent(context, isDark),
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
          ],
        ),
      ),
      // Mobile Navigation
      bottomNavigationBar: MediaQuery.of(context).size.width <= 800
          ? BottomNavigationBar(
              currentIndex: _activeMenuIndex,
              selectedItemColor: const Color(0xFF0C3D98),
              unselectedItemColor: Colors.grey,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  _activeMenuIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.add_business_outlined), label: 'F2F Form'),
                BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map Leads'),
                BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Points'),
                BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), label: 'Collateral'),
              ],
            )
          : null,
    );
  }

  // ==========================================
  // TOP BAR WIDGET
  // ==========================================
  Widget _buildTopBar(BuildContext context, bool isDark, String token) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: App Branding
          Row(
            children: [
              Image.asset(
                'assets/images/AM5 ROYAL TM logo.png',
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.star, color: Color(0xFFD4A33A), size: 26),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AM5 ROYAL',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: const Color(0xFFD4A33A),
                    ),
                  ),
                  Text(
                    'Marketing Agent Portal (Field)',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right Profile / Actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2640) : const Color(0xFFFFF5DA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD4A33A).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Color(0xFFD4A33A), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$_totalReferralPoints pts',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD4A33A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE0F1FF),
                child: const Text('MT', style: TextStyle(color: Color(0xFF0C3D98), fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const SizedBox(width: 8),
              // Logout Action Button
              MouseRegion(
                onEnter: (_) => setState(() => _isHoveredLogout = true),
                onExit: (_) => setState(() => _isHoveredLogout = false),
                child: IconButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEvent.logout());
                  },
                  tooltip: 'Logout',
                  icon: Icon(
                    Icons.logout,
                    size: 20,
                    color: _isHoveredLogout ? Colors.redAccent : (isDark ? Colors.white70 : Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SIDEBAR WIDGET (DESKTOP)
  // ==========================================
  Widget _buildSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Field Menu',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C84A5),
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildSidebarButton(0, Icons.add_business_outlined, 'On-Spot Onboarding', isDark),
          const SizedBox(height: 12),
          _buildSidebarButton(1, Icons.map_outlined, 'Leads & Map Mapping', isDark),
          const SizedBox(height: 12),
          _buildSidebarButton(2, Icons.emoji_events_outlined, 'Rewards & Progress', isDark),
          const SizedBox(height: 12),
          _buildSidebarButton(3, Icons.campaign_outlined, 'Pitch Kit Collateral', isDark),
          const Spacer(),
          // GPS Switch Helper
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEEF5FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0C3D98).withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mock GPS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11)),
                    SizedBox(
                      height: 20,
                      child: Switch(
                        value: _useMockGps,
                        activeThumbColor: const Color(0xFF0C3D98),
                        activeTrackColor: const Color(0xFF0C3D98).withValues(alpha: 0.3),
                        onChanged: (val) {
                          setState(() {
                            _useMockGps = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Bypasses hardware GPS requirements for web/simulator testing.',
                  style: GoogleFonts.outfit(fontSize: 9, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarButton(int index, IconData icon, String title, bool isDark) {
    final isSelected = _activeMenuIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeMenuIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0C3D98) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF0C3D98).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF6C84A5)),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF16315D)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB SELECTION CONTENT HANDLER
  // ==========================================
  Widget _buildActiveTabContent(BuildContext context, bool isDark) {
    switch (_activeMenuIndex) {
      case 0:
        return _buildOnSpotOnboardingTab(context, isDark);
      case 1:
        return _buildLeadsAndMapTab(context, isDark);
      case 2:
        return _buildRewardsProgressTab(context, isDark);
      case 3:
        return _buildCollateralTab(context, isDark);
      default:
        return _buildOnSpotOnboardingTab(context, isDark);
    }
  }

  // ==========================================
  // TAB 1: ON-SPOT ONBOARDING FORM
  // ==========================================
  Widget _buildOnSpotOnboardingTab(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Field Registration Form',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0D3B66)),
        ),
        const SizedBox(height: 4),
        Text(
          'Complete vendor onboarding face-to-face. Capture shop details, geolocation, and photos.',
          style: GoogleFonts.outfit(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C84A5)),
        ),
        const SizedBox(height: 20),

        // Form Fields Container
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD8E6F5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Business Name
              _buildInputLabel('Shop/Business Name', isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _shopNameController,
                style: GoogleFonts.outfit(fontSize: 13),
                decoration: _buildInputDecoration('e.g. Royal Plumbing Hub', Icons.business_outlined, isDark),
              ),
              const SizedBox(height: 16),

              // Owner Name
              _buildInputLabel('Owner Full Name', isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _ownerNameController,
                style: GoogleFonts.outfit(fontSize: 13),
                decoration: _buildInputDecoration('e.g. Rajat Sen', Icons.person_outline, isDark),
              ),
              const SizedBox(height: 16),

              // Contact Number
              _buildInputLabel('Contact Phone Number', isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.outfit(fontSize: 13),
                decoration: _buildInputDecoration('e.g. +91 99887 76655', Icons.phone_android, isDark),
              ),
              const SizedBox(height: 16),

              // Category
              _buildInputLabel('Vendor Category', isDark),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF7FBFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.transparent : const Color(0xFFD8E6F5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                    style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF16315D), fontWeight: FontWeight.w500),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0C3D98)),
                    isExpanded: true,
                    items: _categoriesList.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // GPS Locator Section
              _buildInputLabel('Verify Shop GPS Coordinates', isDark),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E8BF0).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_latitude != null && _longitude != null) ...[
                            Text(
                              'GPS Locked Successfully',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                              style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF16315D), fontWeight: FontWeight.bold),
                            ),
                          ] else ...[
                            Text(
                              'GPS Coordinates Missing',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber[800]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "Fetch Location" below',
                              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C3D98),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLocating ? null : _fetchGPSLocation,
                      icon: _isLocating
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5))
                          : const Icon(Icons.gps_fixed, size: 14, color: Colors.white),
                      label: Text(
                        _isLocating ? 'Locating...' : 'Fetch Location',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Camera Document Scans
              _buildInputLabel('Required Shop & Document Photos', isDark),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildCameraCaptureCard('Shop Front Photo', _shopFrontPhoto, () => _capturePhoto('shop'), itemWidth, isDark),
                      _buildCameraCaptureCard('Owner Photo', _ownerPhoto, () => _capturePhoto('owner'), itemWidth, isDark),
                      _buildCameraCaptureCard('Aadhaar Card Scan', _aadhaarPhoto, () => _capturePhoto('aadhaar'), itemWidth, isDark),
                      _buildCameraCaptureCard('GST Certificate Scan', _gstPhoto, () => _capturePhoto('gst'), itemWidth, isDark),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Register Button
              Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _submitOnSpotOnboarding,
                  child: Text(
                    'Onboard Vendor On-Spot (+50 pts)',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraCaptureCard(String title, XFile? photo, VoidCallback onTap, double width, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF7FBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: photo != null ? const Color(0xFF10B981) : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD8E6F5)),
            width: photo != null ? 1.5 : 1.0,
          ),
        ),
        child: photo != null
            ? Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: kIsWeb
                          ? Image.network(photo.path, fit: BoxFit.cover)
                          : Image.file(File(photo.path), fit: BoxFit.cover),
                    ),
                  ),
                  // Green tick banner
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 10),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, color: Color(0xFF0C3D98), size: 24),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF16315D)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to capture',
                    style: GoogleFonts.outfit(fontSize: 8, color: Colors.grey[500]),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInputLabel(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF16315D),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData prefixIcon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: isDark ? Colors.white30 : const Color(0xFF94A8C5), fontSize: 12),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF0C3D98), size: 16),
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF7FBFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? Colors.transparent : const Color(0xFFD8E6F5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? Colors.transparent : const Color(0xFFD8E6F5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2B7DE1), width: 1.5),
      ),
    );
  }

  // ==========================================
  // TAB 2: LEADS & MAP LIST
  // ==========================================
  Widget _buildLeadsAndMapTab(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Target Areas & Client Map Mapping',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0D3B66)),
        ),
        const SizedBox(height: 4),
        Text(
          'Assigned shops to visit and onboarding checks. Perform direct pitches to sign up local experts.',
          style: GoogleFonts.outfit(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C84A5)),
        ),
        const SizedBox(height: 20),

        // Simulated visual routing map
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD8E6F5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Stack(
              children: [
                // Simulated grid map drawing
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MockMapPainter(isDark),
                  ),
                ),
                // Overlay text card
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.navigation_outlined, color: Color(0xFF2E8BF0), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Active Area Assigned: Madhapur Sector 2, Hyderabad',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Visit Checklist
        Text(
          'Todays Shop Visit Checklist',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF16315D)),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _assignedLeads.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final lead = _assignedLeads[index];
            final isDone = lead['status'] == 'Visited & Onboarded';
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD8E6F5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        lead['status'] = isDone ? 'Pending Visit' : 'Visited & Onboarded';
                      });
                    },
                    icon: Icon(
                      isDone ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isDone ? const Color(0xFF10B981) : Colors.grey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead['shopName'],
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF16315D),
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(lead['address'], style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  // Phone launcher
                  IconButton(
                    onPressed: () async {
                      final url = Uri.parse('tel:${lead['contact']}');
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                    icon: const Icon(Icons.phone, color: Color(0xFF0C3D98), size: 18),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: REWARDS & PROGRESS LOG
  // ==========================================
  Widget _buildRewardsProgressTab(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Rewards & Conversion Progress',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0D3B66)),
        ),
        const SizedBox(height: 4),
        Text(
          'View your daily metrics performance and list of approved/pending on-spot onboarding points.',
          style: GoogleFonts.outfit(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C84A5)),
        ),
        const SizedBox(height: 20),

        // Progress quota tracker
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD8E6F5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Daily Visited Shop Quota', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('$_dailyVisitsCount/$_dailyVisitsTarget visits', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF0C3D98))),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _dailyVisitsCount / _dailyVisitsTarget,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEEF5FC),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0C3D98)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Onboard ${_dailyVisitsTarget - _dailyVisitsCount} more vendors today to fulfill your daily field requirement.',
                style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF6C84A5), fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Logs
        Text(
          'Referrals Reward History',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF16315D)),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD8E6F5)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _performanceHistory.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD8E6F5)),
            itemBuilder: (context, index) {
              final item = _performanceHistory[index];
              final isVerified = item['status'] == 'Verified';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFFF5DA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isVerified ? Icons.check_circle_outline : Icons.pending_outlined,
                        color: isVerified ? const Color(0xFF10B981) : const Color(0xFFD4A33A),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['shop'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('${item['date']} • ${item['status']}', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text('+${item['points']} pts', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF10B981), fontSize: 13)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 4: MARKETING COLLATERAL / SALES PITCH
  // ==========================================
  Widget _buildCollateralTab(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Marketing Pitch Collaterals',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0D3B66)),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide pitches to prospective vendor clients, demonstrate videos, generate QR invites, and show PDFs.',
          style: GoogleFonts.outfit(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C84A5)),
        ),
        const SizedBox(height: 20),

        // Grid cards
        Row(
          children: [
            // PDF Pitch Brochure download
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD8E6F5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
                    const SizedBox(height: 12),
                    Text('Pitch Brochure PDF', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Main partner benefits, commission splits, and payouts schedule details.', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[500]), maxLines: 2),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C3D98), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () async {
                        final url = Uri.parse('https://am5royal.com/brochure.pdf');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening mock PDF link...')));
                        }
                      },
                      icon: const Icon(Icons.download, size: 12, color: Colors.white),
                      label: Text('Download/Share', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Video Player
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD8E6F5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 28),
                    const SizedBox(height: 12),
                    Text('Promo Pitch Video', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('A high-impact 2-minute promotional pitch introducing MSKGRC and AM5.', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[500]), maxLines: 2),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        setState(() {
                          _isPlayingCollateralVideo = !_isPlayingCollateralVideo;
                        });
                      },
                      icon: Icon(_isPlayingCollateralVideo ? Icons.pause : Icons.play_arrow, size: 12, color: Colors.white),
                      label: Text(_isPlayingCollateralVideo ? 'Pause Video' : 'Play Pitch', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Video Player Simulator Box
        if (_isPlayingCollateralVideo) ...[
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.4,
                  child: Image.asset('assets/images/water.png', fit: BoxFit.cover, width: double.infinity),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.movie_outlined, color: Colors.white, size: 36),
                    const SizedBox(height: 10),
                    Text(
                      'Simulating: Pitch Video is Playing...',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text('Showing slides on commission structure & benefits', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Referrer QR Code Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFD8E6F5)),
          ),
          child: Row(
            children: [
              // Mock QR Code Box
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: CustomPaint(
                  painter: _MockQrCodePainter(),
                ),
              ),
              const SizedBox(width: 20),

              // Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Referral QR Link',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF16315D)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Referral ID: EMP-MT992',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0C3D98)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Instruct vendors to scan this code on their personal device. They will immediately download the app pre-filled with your referral credentials.',
                      style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF6C84A5), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// MOCK MAP CUSTOM PAINTER
// ==========================================
class _MockMapPainter extends CustomPainter {
  final bool isDark;
  _MockMapPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    // Draw Grid Lines
    const step = 20.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw Simulated Street Paths
    final roadPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[400]!
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(30, size.height / 2), Offset(size.width - 30, size.height / 2), roadPaint);
    canvas.drawLine(Offset(size.width / 2, 20), Offset(size.width / 2, size.height - 20), roadPaint);
    canvas.drawLine(const Offset(30, 30), Offset(size.width / 2, size.height / 2), roadPaint);

    // Draw Agent Position Pin
    final agentPaint = Paint()..color = const Color(0xFF2E8BF0);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 7.0, agentPaint);

    // Draw Target Pins (Shops)
    final shopPaint1 = Paint()..color = const Color(0xFFEF4444);
    final shopPaint2 = Paint()..color = const Color(0xFF10B981);

    canvas.drawCircle(const Offset(50, 45), 5.0, shopPaint1);
    canvas.drawCircle(Offset(size.width - 60, size.height / 2 + 10), 5.0, shopPaint2);
    canvas.drawCircle(Offset(size.width / 2 - 40, size.height - 40), 5.0, shopPaint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// MOCK QR CODE CUSTOM PAINTER
// ==========================================
class _MockQrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    // Corner Finder Squares
    canvas.drawRect(const Rect.fromLTWH(0, 0, 24, 24), paint);
    canvas.drawRect(const Rect.fromLTWH(4, 4, 16, 16), Paint()..color = Colors.white);
    canvas.drawRect(const Rect.fromLTWH(8, 8, 8, 8), paint);

    canvas.drawRect(Rect.fromLTWH(size.width - 24, 0, 24, 24), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 20, 4, 16, 16), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width - 16, 8, 8, 8), paint);

    canvas.drawRect(Rect.fromLTWH(0, size.height - 24, 24, 24), paint);
    canvas.drawRect(Rect.fromLTWH(4, size.height - 20, 16, 16), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(8, size.height - 16, 8, 8), paint);

    // Random pixels simulator
    final randomPaint = Paint()..color = Colors.black;
    const pixelSize = 4.0;
    for (double y = 28; y < size.height - 28; y += pixelSize * 2) {
      for (double x = 4; x < size.width - 4; x += pixelSize * 2) {
        if ((x + y).toInt() % 3 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, pixelSize, pixelSize), randomPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
