import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/telecaller_vendor_onboard_request_model.dart';
import '../../data/datasources/employee_api_service.dart';
import '../../../../core/di/injection_container.dart' as di;

class TelecallerVendorOnboardPage extends StatefulWidget {
  const TelecallerVendorOnboardPage({super.key});

  @override
  State<TelecallerVendorOnboardPage> createState() => _TelecallerVendorOnboardPageState();
}

class _TelecallerVendorOnboardPageState extends State<TelecallerVendorOnboardPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _mobileController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _alternativeNumberController = TextEditingController();
  
  final _addressController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _radiusController = TextEditingController(text: '5');

  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _businessNameController.dispose();
    _fatherNameController.dispose();
    _emailController.dispose();
    _alternativeNumberController.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final mobile = _mobileController.text.trim();
    final request = TelecallerVendorOnboardRequestModel(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      fatherName: _fatherNameController.text.trim(),
      email: _emailController.text.trim(),
      alternativeNumber: _alternativeNumberController.text.trim(),
      businessName: _businessNameController.text.trim(),
      aadhaarNumber: '',
      address: _addressController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      serviceRadiusKm: int.tryParse(_radiusController.text.trim()) ?? 5,
      categories: [],
      services: [],
    );

    try {
      final employeeApiService = di.sl<EmployeeApiService>();
      await employeeApiService.telecallerSaveProfile(mobile, request);

      if (mounted) {
        context.push('/telecaller/map-screen', extra: {
          'mobile': mobile,
          'request': request,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save vendor profile: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Onboard Partner',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Base Color
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            ),
          ),
          
          // Glowing mesh background spheres
          Positioned(
            top: -100,
            left: -100,
            child: IgnorePointer(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2563EB).withValues(alpha: isDark ? 0.12 : 0.06),
                      const Color(0xFF2563EB).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.1 : 0.05),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Scrollable form contents
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Hero Introduction Header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 8, 4, 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vendor Registration'.toUpperCase(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Onboard New Vendor',
                                      style: GoogleFonts.outfit(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        letterSpacing: -0.5,
                                        height: 1.15,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Complete basic profile information, location details, and KYC status to register this vendor and configure their service categories.',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w400,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Card 1: Personal Details
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.45) : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF0F172A).withValues(alpha: 0.03),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person_rounded,
                                            color: Color(0xFF2563EB),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Personal Details',
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Personal details field grid
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final useDoubleColumn = constraints.maxWidth > 550;
                                        return Column(
                                          children: [
                                            if (useDoubleColumn) ...[
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _OnboardTextField(
                                                      controller: _mobileController,
                                                      label: 'Mobile Number *',
                                                      prefixIcon: Icons.phone_rounded,
                                                      keyboardType: TextInputType.phone,
                                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: _OnboardTextField(
                                                      controller: _firstNameController,
                                                      label: 'First Name *',
                                                      prefixIcon: Icons.person_outline_rounded,
                                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _OnboardTextField(
                                                      controller: _lastNameController,
                                                      label: 'Last Name',
                                                      prefixIcon: Icons.person_outline_rounded,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: _OnboardTextField(
                                                      controller: _fatherNameController,
                                                      label: 'Father Name',
                                                      prefixIcon: Icons.family_restroom_rounded,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _OnboardTextField(
                                                      controller: _emailController,
                                                      label: 'Email Address',
                                                      prefixIcon: Icons.email_outlined,
                                                      keyboardType: TextInputType.emailAddress,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: _OnboardTextField(
                                                      controller: _alternativeNumberController,
                                                      label: 'Alternative Number',
                                                      prefixIcon: Icons.phone_android_rounded,
                                                      keyboardType: TextInputType.phone,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              _OnboardTextField(
                                                controller: _businessNameController,
                                                label: 'Business Name *',
                                                prefixIcon: Icons.storefront_rounded,
                                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                              ),
                                            ] else ...[
                                              _OnboardTextField(
                                                controller: _mobileController,
                                                label: 'Mobile Number *',
                                                prefixIcon: Icons.phone_rounded,
                                                keyboardType: TextInputType.phone,
                                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                              ),
                                              const SizedBox(height: 16),
                                              _OnboardTextField(
                                                controller: _firstNameController,
                                                label: 'First Name *',
                                                prefixIcon: Icons.person_outline_rounded,
                                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                              ),
                                              const SizedBox(height: 16),
                                              _OnboardTextField(
                                                controller: _lastNameController,
                                                label: 'Last Name',
                                                prefixIcon: Icons.person_outline_rounded,
                                              ),
                                              const SizedBox(height: 16),
                                              _OnboardTextField(
                                                controller: _fatherNameController,
                                                label: 'Father Name',
                                                prefixIcon: Icons.family_restroom_rounded,
                                              ),
                                              const SizedBox(height: 16),
                                              _OnboardTextField(
                                                controller: _businessNameController,
                                                label: 'Business Name *',
                                                prefixIcon: Icons.storefront_rounded,
                                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                              ),
                                            ]
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Card 2: Address Details
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.45) : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF0F172A).withValues(alpha: 0.03),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.location_on_rounded,
                                            color: Color(0xFF8B5CF6),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Address Details',
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    _OnboardTextField(
                                      controller: _addressController,
                                      label: 'Present / Current Address *',
                                      prefixIcon: Icons.home_work_outlined,
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Address grid layout
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final useDoubleColumn = constraints.maxWidth > 550;
                                        return Column(
                                          children: [
                                            if (useDoubleColumn) ...[
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _OnboardTextField(
                                                      controller: _cityController,
                                                      label: 'City *',
                                                      prefixIcon: Icons.location_city_rounded,
                                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: _OnboardTextField(
                                                      controller: _stateController,
                                                      label: 'State *',
                                                      prefixIcon: Icons.map_rounded,
                                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _OnboardTextField(
                                                      controller: _pincodeController,
                                                      label: 'Pincode *',
                                                      prefixIcon: Icons.pin_drop_rounded,
                                                      keyboardType: TextInputType.number,
                                                      validator: (val) {
                                                        if (val == null || val.isEmpty) return 'Required';
                                                        if (val.length != 6 || int.tryParse(val) == null) {
                                                          return 'Must be 6 digits';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: _OnboardTextField(
                                                      controller: _radiusController,
                                                      label: 'Service Radius (Km) *',
                                                      prefixIcon: Icons.explore_rounded,
                                                      keyboardType: TextInputType.number,
                                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ] else ...[
                                              _OnboardTextField(
                                                controller: _cityController,
                                                label: 'City *',
                                                prefixIcon: Icons.location_city_rounded,
                                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                              ),
                                              const SizedBox(height: 16),
                                              _OnboardTextField(
                                                controller: _stateController,
                                                label: 'State *',
                                                prefixIcon: Icons.map_rounded,
                                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                              ),
                                              const SizedBox(height: 16),
                                              _OnboardTextField(
                                                controller: _pincodeController,
                                                label: 'Pincode *',
                                                prefixIcon: Icons.pin_drop_rounded,
                                                keyboardType: TextInputType.number,
                                                validator: (val) {
                                                  if (val == null || val.isEmpty) return 'Required';
                                                  if (val.length != 6 || int.tryParse(val) == null) {
                                                    return 'Must be 6 digits';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                              _OnboardTextField(
                                                controller: _radiusController,
                                                label: 'Service Radius (Km) *',
                                                prefixIcon: Icons.explore_rounded,
                                                keyboardType: TextInputType.number,
                                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                              ),
                                            ]
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Submit CTA Button
                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2563EB),
                                      Color(0xFF1D4ED8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: _isLoading ? null : _submitForm,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Next (Select Categories)',
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _OnboardTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _OnboardTextField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF2563EB);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(
        fontSize: 14,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.outfit(
          color: primaryColor,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(
            prefixIcon,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            size: 20,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        filled: true,
        fillColor: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.35)
            : const Color(0xFFF1F5F9).withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
