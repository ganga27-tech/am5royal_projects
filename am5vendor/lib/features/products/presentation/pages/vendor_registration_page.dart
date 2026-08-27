import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/onboarding_session_guard.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/product_model.dart';
import '../../../auth/data/models/vendor_registration_request_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/bloc/register_vendor_bloc.dart';
import '../../../auth/presentation/bloc/register_vendor_event.dart';
import '../../../auth/presentation/bloc/register_vendor_state.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../widgets/location_picker_map_widget.dart';
import '../../../../core/services/analytics_service.dart';

class VendorRegistrationPage extends ConsumerStatefulWidget {
  final int mainCategoryId;
  final String mainCategoryName;
  final List<SubCategoryItem> selectedSubCategories;
  final List<SubSubCategoryItem> selectedServiceTypes;
  final bool isTelecallerOnboarded;

  const VendorRegistrationPage({
    super.key,
    required this.mainCategoryId,
    required this.mainCategoryName,
    required this.selectedSubCategories,
    required this.selectedServiceTypes,
    this.isTelecallerOnboarded = false,
  });

  @override
  ConsumerState<VendorRegistrationPage> createState() =>
      _VendorRegistrationPageState();
}

class _VendorRegistrationPageState
    extends ConsumerState<VendorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _mapKey = GlobalKey<LocationPickerMapWidgetState>();
  bool _isSingleService = true;

  // Controllers
  final _vendorNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _fatherOrBusinessController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _altMobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _radiusController = TextEditingController(text: '10');

  // Focus Nodes for scrolling to first invalid field
  final _vendorNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _fatherOrBusinessFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _altMobileFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _streetFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _districtFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _pincodeFocus = FocusNode();
  final _radiusFocus = FocusNode();

  // Verification & Location State Variables
  bool _isPaymentProcessing = false;
  bool _isSavingProfile = false;
  bool _isEditMode = false;

  double? _latitude;
  double? _longitude;

  InputDecoration _buildInputDecoration({
    required String labelText,
    Widget? prefixIcon,
    String? hintText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null
          ? IconTheme(
              data: IconThemeData(
                color: isDark ? AppColors.accentLight : AppColors.primary,
              ),
              child: prefixIcon,
            )
          : null,
      labelStyle: GoogleFonts.outfit(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      floatingLabelStyle: GoogleFonts.outfit(
        color: isDark ? AppColors.accentLight : AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor:
          isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0F7FF),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppColors.accent : AppColors.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.4)
            : AppColors.surfaceVariant.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? AppColors.accentLight : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isSingleService = widget.selectedServiceTypes.isEmpty;
    _loadLocalUserData();
    _fetchLocation();
    _fetchProfileData();
  }

  Future<void> _loadLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final localPhone =
        prefs.getString('user_phone') ?? prefs.getString('mobile') ?? '';
    final localEmail =
        prefs.getString('user_email') ?? prefs.getString('email') ?? '';
    if (mounted) {
      setState(() {
        if (_mobileController.text.isEmpty && localPhone.isNotEmpty) {
          _mobileController.text = localPhone;
        }
        if (_emailController.text.isEmpty && localEmail.isNotEmpty) {
          _emailController.text = localEmail;
        }
      });
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      final dio = di.sl<Dio>();
      final response = await dio.get('/vendors/me/profile');
      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          if (_vendorNameController.text.isEmpty) {
            _vendorNameController.text = data['first_name'] ?? '';
          }
          if (_lastNameController.text.isEmpty) {
            _lastNameController.text = data['last_name'] ?? '';
          }
          if (_fatherOrBusinessController.text.isEmpty) {
            _fatherOrBusinessController.text = data['father_name'] ?? '';
            if (_fatherOrBusinessController.text.isEmpty) {
              _fatherOrBusinessController.text = data['business_name'] ?? '';
            }
          }
          if (_mobileController.text.isEmpty) {
            _mobileController.text =
                (data['mobile'] ?? data['phone'] ?? data['mobile_number'] ?? '')
                    .toString();
          }
          final fetchedEmail = (data['email'] ?? '').toString();
          if (_emailController.text.isEmpty ||
              _emailController.text.contains('@am5royal.com')) {
            if (!fetchedEmail.contains('@am5royal.com')) {
              _emailController.text = fetchedEmail;
            } else {
              _emailController.text = '';
            }
          }
          if (_altMobileController.text.isEmpty) {
            _altMobileController.text = data['alt_mobile'] ??
                data['alternate_mobile'] ??
                data['alternative_mobile'] ??
                '';
          }
          if (_addressController.text.isEmpty) {
            _addressController.text = data['address'] ?? '';
          }
          if (_streetController.text.isEmpty) {
            _streetController.text = data['street'] ?? '';
          }
          if (_cityController.text.isEmpty) {
            _cityController.text = data['city'] ?? '';
          }
          if (_districtController.text.isEmpty) {
            _districtController.text = data['district'] ?? '';
          }
          if (_stateController.text.isEmpty) {
            _stateController.text = data['state'] ?? '';
          }
          if (_pincodeController.text.isEmpty) {
            _pincodeController.text = data['pincode'] ?? '';
          }
          if (_radiusController.text.isEmpty ||
              _radiusController.text == '10') {
            final fetchedRadius =
                data['service_radius_km'] ?? data['service_radius'];
            if (fetchedRadius != null) {
              _radiusController.text = fetchedRadius.toString();
            }
          }

          if (data['latitude'] != null) {
            _latitude = double.tryParse(data['latitude'].toString());
          }
          if (data['longitude'] != null) {
            _longitude = double.tryParse(data['longitude'].toString());
          }

          _isEditMode = (data['first_name'] ?? '').toString().trim().isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch profile data for prefill: $e');
    }
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _lastNameController.dispose();
    _fatherOrBusinessController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _radiusController.dispose();

    _vendorNameFocus.dispose();
    _lastNameFocus.dispose();
    _fatherOrBusinessFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _altMobileFocus.dispose();
    _addressFocus.dispose();
    _streetFocus.dispose();
    _cityFocus.dispose();
    _districtFocus.dispose();
    _stateFocus.dispose();
    _pincodeFocus.dispose();
    _radiusFocus.dispose();

    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationDialog(
            'Location services are disabled. Please enable them in settings.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationDialog(
              'Location permission denied. Please allow location access to register.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationDialog(
            'Location permissions are permanently denied. Please enable them in settings.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Automatically trigger reverse geocoding on map widget to fill location fields (City, District, State, Pincode, Address)
      _mapKey.currentState?.moveToLocation(
        LatLng(position.latitude, position.longitude),
        zoom: 16.0,
        triggerGeocode: true,
      );
    } catch (e) {
      _showLocationDialog(
          'Unable to fetch current location. Please enable location services.');
    }
  }

  void _showLocationDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _submitRegistration() {
    final isFormKeyValid = _formKey.currentState?.validate() ?? false;

    if (FormValidators.validateFirstName(_vendorNameController.text) != null) {
      _vendorNameFocus.requestFocus();
      return;
    }
    if (FormValidators.validateLastName(_lastNameController.text) != null) {
      _lastNameFocus.requestFocus();
      return;
    }
    if (_isSingleService) {
      if (FormValidators.validateFatherName(_fatherOrBusinessController.text) !=
          null) {
        _fatherOrBusinessFocus.requestFocus();
        return;
      }
    } else {
      if (FormValidators.validateBusinessName(
              _fatherOrBusinessController.text) !=
          null) {
        _fatherOrBusinessFocus.requestFocus();
        return;
      }
    }
    if (FormValidators.validateEmail(_emailController.text) != null) {
      _emailFocus.requestFocus();
      return;
    }
    if (FormValidators.validateMobileNumber(_mobileController.text) != null) {
      _mobileFocus.requestFocus();
      return;
    }
    if (FormValidators.validateAltMobile(_altMobileController.text) != null) {
      _altMobileFocus.requestFocus();
      return;
    }
    if (FormValidators.validateAddress(_addressController.text) != null) {
      _addressFocus.requestFocus();
      return;
    }
    if (FormValidators.validatePincode(_pincodeController.text) != null) {
      _pincodeFocus.requestFocus();
      return;
    }
    if (FormValidators.validateServiceRadius(_radiusController.text) != null) {
      _radiusFocus.requestFocus();
      return;
    }

    if (!isFormKeyValid) return;

    final firstName = _vendorNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final fatherName =
        _isSingleService ? _fatherOrBusinessController.text.trim() : null;
    final businessName = !_isSingleService
        ? _fatherOrBusinessController.text.trim()
        : '${_vendorNameController.text.trim()} Services';

    final cityVal = _cityController.text.trim().isEmpty
        ? 'Hyderabad'
        : _cityController.text.trim();
    final stateVal = _stateController.text.trim().isEmpty
        ? 'Telangana'
        : _stateController.text.trim();
    final pincodeVal = _pincodeController.text.trim().isEmpty
        ? '500001'
        : _pincodeController.text.trim();

    if (_isEditMode) {
      _saveProfileUpdate(
        firstName: firstName,
        lastName: lastName,
        fatherName: fatherName,
        businessName: businessName,
      );
      return;
    }

    final registerBloc = ref.read(registerVendorBlocProvider);

    final subCategoryIds = widget.selectedSubCategories
        .map((s) => int.tryParse(s.id) ?? 0)
        .where((id) => id > 0)
        .toList();

    final categoriesReq = [
      ServiceCategorySelection(
        mainCategoryId: widget.mainCategoryId,
        subCategoryIds: subCategoryIds,
      ),
    ];

    final request = VendorRegistrationRequestModel(
      firstName: firstName,
      lastName: lastName.isEmpty ? null : lastName,
      fatherName: fatherName != null && fatherName.isEmpty ? null : fatherName,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      mobile: _mobileController.text.trim().isEmpty
          ? null
          : _mobileController.text.trim(),
      altMobile: _altMobileController.text.trim().isEmpty
          ? null
          : _altMobileController.text.trim(),
      businessName: businessName,
      aadhaarNumber: '',
      address: _addressController.text.trim(),
      street: _streetController.text.trim().isEmpty
          ? null
          : _streetController.text.trim(),
      city: cityVal,
      district: _districtController.text.trim().isEmpty
          ? null
          : _districtController.text.trim(),
      state: stateVal,
      pincode: pincodeVal,
      latitude: _latitude ?? 17.3850,
      longitude: _longitude ?? 78.4867,
      serviceRadiusKm: int.tryParse(_radiusController.text.trim()) ?? 10,
      profileImage: '',
      categories: categoriesReq,
    );

    AnalyticsService().logSignUp(signUpMethod: 'VendorRegistration');
    registerBloc.add(RegisterVendorEvent.submit(request));
  }

  Future<void> _saveProfileUpdate({
    required String firstName,
    required String lastName,
    String? fatherName,
    required String businessName,
  }) async {
    setState(() => _isSavingProfile = true);
    try {
      final dio = di.sl<Dio>();
      await dio.put(
        '/vendors/me/profile',
        data: {
          'first_name': firstName,
          'last_name': lastName.isEmpty ? null : lastName,
          'father_name':
              fatherName != null && fatherName.isEmpty ? null : fatherName,
          'business_name': businessName,
          if (_altMobileController.text.trim().isNotEmpty)
            'alt_mobile': _altMobileController.text.trim(),
          'address': _addressController.text.trim(),
          if (_streetController.text.trim().isNotEmpty)
            'street': _streetController.text.trim(),
          'city': _cityController.text.trim().isEmpty
              ? 'Hyderabad'
              : _cityController.text.trim(),
          if (_districtController.text.trim().isNotEmpty)
            'district': _districtController.text.trim(),
          'state': _stateController.text.trim().isEmpty
              ? 'Telangana'
              : _stateController.text.trim(),
          'pincode': _pincodeController.text.trim().isEmpty
              ? '500001'
              : _pincodeController.text.trim(),
          'service_radius_km':
              int.tryParse(_radiusController.text.trim()) ?? 10,
          if (_latitude != null) 'latitude': _latitude,
          if (_longitude != null) 'longitude': _longitude,
        },
      );
      if (!mounted) return;
      OnboardingSessionGuard.instance.unlockOnForwardProgress();
      context.go(
        '/vendor-availability',
        extra: {
          'mainCategoryId': widget.mainCategoryId,
          'mainCategoryName': widget.mainCategoryName,
          'selectedSubCategories': widget.selectedSubCategories,
          'selectedServiceTypes': widget.selectedServiceTypes,
          'firstName': firstName,
          'lastName': lastName,
          'businessName': businessName,
          'isSingleService': _isSingleService,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update details: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  void _handleBackNav() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/map');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final bodyTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final brandTheme = Theme.of(context).copyWith(
      textTheme: GoogleFonts.outfitTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).apply(
        bodyColor: bodyTextColor,
        displayColor: primaryTextColor,
      ),
    );

    return Theme(
      data: brandTheme,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _handleBackNav();
          }
        },
        child: BlocListener<RegisterVendorBloc, RegisterVendorState>(
          bloc: ref.watch(registerVendorBlocProvider),
          listener: (context, state) {
            state.maybeWhen(
              loading: () {
                setState(() {
                  _isPaymentProcessing = true;
                });
              },
              success: (response) async {
                OnboardingSessionGuard.instance.unlockOnForwardProgress();
                final prefs = di.sl<SharedPreferences>();
                await prefs.setBool('is_new_user', false);
                setState(() {
                  _isPaymentProcessing = false;
                });
                if (context.mounted) {
                  context.go(
                    '/vendor-availability',
                    extra: {
                      'firstName': _vendorNameController.text.trim(),
                      'lastName': _lastNameController.text.trim(),
                      'businessName': !_isSingleService
                          ? _fatherOrBusinessController.text.trim()
                          : '${_vendorNameController.text.trim()} Services',
                      'isSingleService': _isSingleService,
                      'mainCategoryId': widget.mainCategoryId,
                      'mainCategoryName': widget.mainCategoryName,
                      'selectedSubCategories': widget.selectedSubCategories,
                      'selectedServiceTypes': widget.selectedServiceTypes,
                    },
                  );
                }
              },
              error: (message) {
                setState(() {
                  _isPaymentProcessing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registration failed: $message'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              validationError: (message) {
                setState(() {
                  _isPaymentProcessing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Validation error: $message'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              orElse: () {},
            );
          },
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
            appBar: AppBar(
              title: Text(
                _isEditMode ? 'Edit Partner Details' : 'Partner Registration',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : AppColors.primary),
                onPressed: _handleBackNav,
              ),
            ),
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                Positioned.fill(
                  child: Semantics(
                    label: 'Verified Service Provider',
                    image: true,
                    child: Image.asset(
                      'assets/images/water.png',
                      fit: BoxFit.cover,
                      opacity: AlwaysStoppedAnimation(isDark ? 0.15 : 0.85),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isDark
                              ? Colors.black.withValues(alpha: 0.85)
                              : Colors.white.withValues(alpha: 0.35),
                          isDark
                              ? Colors.black.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.15),
                          isDark
                              ? Colors.black.withValues(alpha: 0.95)
                              : Colors.white.withValues(alpha: 0.45),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: _isPaymentProcessing || _isSavingProfile
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                  color: AppColors.primary),
                              const SizedBox(height: 24),
                              Text(
                                _isSavingProfile
                                    ? 'Saving your details...'
                                    : 'Registering credentials...',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      isDark ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ResponsiveLayout(
                          mobile: _buildMobileLayout(context),
                          tablet: _buildMobileLayout(context),
                          desktop: _buildDesktopLayout(context),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: _buildRegistrationCard(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Column: Branding and onboarding info
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Center(
                          child: SizedBox(
                            height: 140,
                            child: Semantics(
                              label: 'AM5ROYAL Vendor Signup',
                              image: true,
                              child: Image.asset(
                                'assets/images/AM5 ROYAL TM logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          'AM5 ROYAL',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F4C81),
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Slogan Divider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Color(0xFF0F4C81),
                                thickness: 1.2,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: Color(0xFF0F4C81),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'TRUST  •  QUALITY  •  LOYALTY',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF0F4C81),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: Color(0xFF0F4C81),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Color(0xFF0F4C81),
                                thickness: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Subtitle
                        Text(
                          'Partner Onboarding',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F4C81),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Join our network of verified professionals and grow your business today. Fill out your registration details on the right to get started.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: const Color(0xFF6C84A5),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right Column: Registration Card
                Expanded(
                  flex: 6,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: _buildRegistrationCard(context),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1E1E).withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormSection(
                title: 'Personal Information',
                icon: Icons.person_rounded,
                isDark: isDark,
                children: [
                  TextFormField(
                    controller: _vendorNameController,
                    focusNode: _vendorNameFocus,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'First Name',
                      prefixIcon: const Icon(Icons.person_rounded),
                    ),
                    validator: FormValidators.validateFirstName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                    validator: FormValidators.validateLastName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    readOnly: _emailController.text.trim().isNotEmpty,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9@._\-\+]')),
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_rounded),
                    ),
                    validator: FormValidators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mobileController,
                    focusNode: _mobileFocus,
                    readOnly: _mobileController.text.trim().isNotEmpty,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'Mobile Number',
                      hintText: 'e.g. 9876543210',
                      prefixIcon: const Icon(Icons.phone_rounded),
                    ),
                    validator: FormValidators.validateMobileNumber,
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _altMobileController,
                    focusNode: _altMobileFocus,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'Alternative Mobile Number (Optional)',
                      hintText: 'e.g. 9876543210',
                      prefixIcon: const Icon(Icons.phone_android_rounded),
                    ),
                    validator: FormValidators.validateAltMobile,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFormSection(
                title: 'Business & Service Area',
                icon: Icons.store_rounded,
                isDark: isDark,
                children: [
                  TextFormField(
                    controller: _fatherOrBusinessController,
                    focusNode: _fatherOrBusinessFocus,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s.]')),
                    ],
                    decoration: _buildInputDecoration(
                      labelText: _isSingleService
                          ? "Father's Name (S/o)"
                          : 'Name of the Business',
                      prefixIcon: Icon(_isSingleService
                          ? Icons.family_restroom_rounded
                          : Icons.store_rounded),
                    ),
                    validator: (value) => _isSingleService
                        ? FormValidators.validateFatherName(value)
                        : FormValidators.validateBusinessName(value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    focusNode: _addressFocus,
                    decoration: _buildInputDecoration(
                      labelText: 'Address in Full',
                      prefixIcon: const Icon(Icons.location_on_rounded),
                    ),
                    validator: FormValidators.validateAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _streetController,
                    focusNode: _streetFocus,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9\s,.\-\/#]')),
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'Street / Area (Optional)',
                      prefixIcon: const Icon(Icons.add_road_rounded),
                    ),
                    validator: FormValidators.validateStreet,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _districtController,
                    focusNode: _districtFocus,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s.\-]')),
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'District',
                      prefixIcon: const Icon(Icons.location_city_outlined),
                    ),
                    validator: FormValidators.validateDistrict,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    focusNode: _cityFocus,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s.\-]')),
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'City',
                      prefixIcon: const Icon(Icons.location_city_rounded),
                    ),
                    validator: FormValidators.validateCity,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stateController,
                    focusNode: _stateFocus,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s.\-]')),
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'State',
                      prefixIcon: const Icon(Icons.map_rounded),
                    ),
                    validator: FormValidators.validateState,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pincodeController,
                    focusNode: _pincodeFocus,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _buildInputDecoration(
                      labelText: 'Pincode',
                      prefixIcon: const Icon(Icons.pin_drop_rounded),
                    ),
                    validator: FormValidators.validatePincode,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _radiusController,
                    focusNode: _radiusFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _buildInputDecoration(
                      labelText: 'Radius (Km)',
                      prefixIcon: const Icon(Icons.radar_rounded),
                    ),
                    validator: FormValidators.validateServiceRadius,
                  ),
                  const SizedBox(height: 16),
                  LocationPickerMapWidget(
                    key: _mapKey,
                    initialLatitude: _latitude ?? 17.3850,
                    initialLongitude: _longitude ?? 78.4867,
                    onLocationSelected: (details) {
                      setState(() {
                        _latitude = details.latitude;
                        _longitude = details.longitude;
                        if (details.street != null &&
                            details.street!.isNotEmpty) {
                          _streetController.text = details.street!;
                        }
                        if (details.city != null && details.city!.isNotEmpty) {
                          _cityController.text = details.city!;
                        }
                        if (details.district != null &&
                            details.district!.isNotEmpty) {
                          _districtController.text = details.district!;
                        }
                        if (details.state != null &&
                            details.state!.isNotEmpty) {
                          _stateController.text = details.state!;
                        }
                        if (details.pincode != null &&
                            details.pincode!.isNotEmpty) {
                          final cleanPin =
                              details.pincode!.replaceAll(RegExp(r'\D'), '');
                          if (cleanPin.length == 6) {
                            _pincodeController.text = cleanPin;
                          }
                        }
                        if (details.address != null &&
                            details.address!.isNotEmpty) {
                          _addressController.text = details.address!;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: (_isPaymentProcessing || _isSavingProfile)
                      ? null
                      : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isEditMode ? 'SAVE & CONTINUE' : 'REGISTER',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
