import 'dart:io';
import 'package:am5vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:am5vendor/features/auth/presentation/bloc/auth_event.dart';
import 'package:am5vendor/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../data/models/vendor_profile_model.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/api_client.dart';

// --- Spring Physics Click Effect ---
class SpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const SpringButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh the profile to get the absolute latest status on screen entry
    context.read<ProfileBloc>().add(FetchProfileEvent());
    return const _EditProfileView();
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = di.sl<ApiClient>();
  final ImagePicker _imagePicker = ImagePicker();

  File? _bannerImageFile;
  bool _isBannerUploading = false;
  String? _bannerUrl; // current stored URL

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _businessNameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _mobileController;
  late TextEditingController _descriptionController;
  late TextEditingController _highlightsController;
  late TextEditingController _aboutController;
  late TextEditingController _additionalController;
  late TextEditingController _altContactController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _fatherNameController = TextEditingController();
    _businessNameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _pincodeController = TextEditingController();
    _mobileController = TextEditingController();
    _descriptionController = TextEditingController();
    _highlightsController = TextEditingController();
    _aboutController = TextEditingController();
    _additionalController = TextEditingController();
    _altContactController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fatherNameController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _mobileController.dispose();
    _descriptionController.dispose();
    _highlightsController.dispose();
    _aboutController.dispose();
    _additionalController.dispose();
    _altContactController.dispose();
    super.dispose();
  }

  void _populateFields(VendorProfileModel profile) {
    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _fatherNameController.text = profile.fatherName ?? '';
    _businessNameController.text = profile.businessName ?? '';
    _addressController.text = profile.address ?? '';
    _cityController.text = profile.city ?? '';
    _stateController.text = profile.state ?? '';
    _pincodeController.text = profile.pincode ?? '';
    _mobileController.text = profile.mobile ?? '';
    _descriptionController.text = profile.businessDescription ?? '';
    _highlightsController.text = (profile.businessHighlights ?? []).join(', ');
    _aboutController.text = profile.aboutBusiness ?? '';
    _additionalController.text = profile.additionalBusinessInfo ?? '';
    _altContactController.text = profile.alternativeContactNumber ?? '';
    _bannerUrl = profile.backgroundBanner;
  }

  Future<void> _pickAndUploadBanner() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Banner image must be under 10MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _bannerImageFile = file;
        _isBannerUploading = true;
      });

      // Upload to /vendor/management/media → get URL
      final formData = FormData.fromMap({
        'file':
            await MultipartFile.fromFile(picked.path, filename: picked.name),
      });
      final response =
          await _apiClient.dio.post('/vendor/management/media', data: formData);
      final uploadedUrl = response.data['url'] as String?;

      if (uploadedUrl != null && mounted) {
        setState(() {
          _bannerUrl = uploadedUrl;
          _isBannerUploading = false;
        });
        // Save to profile immediately
        final bloc = context.read<ProfileBloc>();
        final currentState = bloc.state;
        VendorProfileModel? profile;
        if (currentState is ProfileLoaded) profile = currentState.profile;
        if (currentState is ProfileUpdateSuccess)
          profile = currentState.profile;
        if (profile != null) {
          bloc.add(UpdateProfileEvent(
              profile.copyWith(backgroundBanner: uploadedUrl)));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Banner updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBannerUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Banner upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBannerSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Business Banner",
          style: GoogleFonts.outfit(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isBannerUploading ? null : _pickAndUploadBanner,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.5)
                    : AppColors.accent.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background: local file > remote URL > placeholder
                  if (_bannerImageFile != null)
                    Image.file(_bannerImageFile!, fit: BoxFit.cover)
                  else if (_bannerUrl != null && _bannerUrl!.isNotEmpty)
                    Image.network(
                      _bannerUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildBannerPlaceholder(isDark),
                    )
                  else
                    _buildBannerPlaceholder(isDark),

                  // Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.45),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Upload button / loader
                  Center(
                    child: _isBannerUploading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _bannerUrl != null
                                    ? 'Change Banner'
                                    : 'Upload Banner',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'JPG, PNG · Max 10 MB',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 11,
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
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildBannerPlaceholder(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkBackground]
              : [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.accent.withValues(alpha: 0.1)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  void _onSave(VendorProfileModel currentProfile) {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = currentProfile.copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        fatherName: _fatherNameController.text,
        businessName: _businessNameController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
        businessDescription: _descriptionController.text,
        businessHighlights: _highlightsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        aboutBusiness: _aboutController.text,
        additionalBusinessInfo: _additionalController.text,
        alternativeContactNumber: _altContactController.text,
      );
      context.read<ProfileBloc>().add(UpdateProfileEvent(updatedProfile));
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account?\n\n'
            'You will have a 30-day grace period. If you do not log back in within 30 days, '
            'your account and data will be permanently soft-deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(const AuthEvent.deleteAccount());
              },
              child: const Text('Delete',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFieldStack({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool readOnly = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: readOnly ? FontWeight.bold : FontWeight.w500,
              color: readOnly
                  ? (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary)
                  : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                prefixIcon,
                color: readOnly
                    ? Colors.grey
                    : (isDark ? AppColors.accent : AppColors.primaryLight),
                size: 18,
              ),
              filled: true,
              fillColor: readOnly
                  ? (isDark
                      ? AppColors.darkSurfaceVariant.withValues(alpha: 0.4)
                      : Colors.grey[100])
                  : (isDark ? AppColors.darkSurfaceVariant : Colors.white),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.5)
                      : AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.5)
                      : AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: readOnly ? Colors.transparent : AppColors.accent,
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (!readOnly && (value == null || value.trim().isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            initial: () {
              context.go('/login');
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            },
            orElse: () {},
          );
        },
        child: Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
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
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Edit Profile',
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
                                    AppColors.darkSurface
                                        .withValues(alpha: 0.8),
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
                    child: BlocConsumer<ProfileBloc, ProfileState>(
                      listener: (context, state) {
                        if (state is ProfileUpdateSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (state is ProfileError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is ProfileLoading) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height - 180,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.accent),
                              ),
                            ),
                          );
                        } else if (state is ProfileLoaded ||
                            state is ProfileUpdating ||
                            state is ProfileUpdateSuccess) {
                          VendorProfileModel profile;
                          if (state is ProfileLoaded) {
                            profile = state.profile;
                          } else if (state is ProfileUpdating) {
                            profile = state.profile;
                          } else {
                            profile = (state as ProfileUpdateSuccess).profile;
                          }

                          // Populate fields on initial load
                          if (state is ProfileLoaded &&
                              _firstNameController.text.isEmpty &&
                              _lastNameController.text.isEmpty) {
                            _populateFields(profile);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Banner Section
                                  _buildBannerSection(isDark),

                                  // Personal Details Section Card
                                  Text(
                                    "Personal Details",
                                    style: GoogleFonts.outfit(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurface
                                              .withValues(alpha: 0.85)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.darkBorder
                                                .withValues(alpha: 0.5)
                                            : AppColors.border
                                                .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildFieldStack(
                                          controller: _mobileController,
                                          label: 'Mobile Number',
                                          prefixIcon:
                                              Icons.phone_android_rounded,
                                          readOnly: true,
                                        ),
                                        _buildFieldStack(
                                          controller: _firstNameController,
                                          label: 'First Name',
                                          prefixIcon:
                                              Icons.person_outline_rounded,
                                        ),
                                        _buildFieldStack(
                                          controller: _lastNameController,
                                          label: 'Last Name',
                                          prefixIcon:
                                              Icons.person_outline_rounded,
                                        ),
                                        _buildFieldStack(
                                          controller: _fatherNameController,
                                          label: 'Father Name',
                                          prefixIcon: Icons.face_rounded,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Business Details Section Card
                                  Text(
                                    "Business Details",
                                    style: GoogleFonts.outfit(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurface
                                              .withValues(alpha: 0.85)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.darkBorder
                                                .withValues(alpha: 0.5)
                                            : AppColors.border
                                                .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildFieldStack(
                                          controller: _businessNameController,
                                          label: 'Business Name',
                                          prefixIcon: Icons.storefront_rounded,
                                        ),
                                        _buildFieldStack(
                                          controller: _addressController,
                                          label: 'Address',
                                          prefixIcon:
                                              Icons.location_on_outlined,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildFieldStack(
                                                controller: _cityController,
                                                label: 'City',
                                                prefixIcon:
                                                    Icons.location_city_rounded,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: _buildFieldStack(
                                                controller: _stateController,
                                                label: 'State',
                                                prefixIcon: Icons.map_rounded,
                                              ),
                                            ),
                                          ],
                                        ),
                                        _buildFieldStack(
                                          controller: _pincodeController,
                                          label: 'Pincode',
                                          prefixIcon: Icons.pin_drop_rounded,
                                        ),
                                        _buildFieldStack(
                                          controller: _altContactController,
                                          label: 'Alternative Contact Number',
                                          prefixIcon:
                                              Icons.phone_android_rounded,
                                        ),
                                        _buildFieldStack(
                                          controller: _descriptionController,
                                          label: 'Business Description',
                                          prefixIcon: Icons.description_rounded,
                                        ),
                                        _buildFieldStack(
                                          controller: _highlightsController,
                                          label:
                                              'Business Highlights (comma separated)',
                                          prefixIcon:
                                              Icons.featured_play_list_rounded,
                                        ),
                                        _buildFieldStack(
                                          controller: _aboutController,
                                          label: 'About Business',
                                          prefixIcon:
                                              Icons.info_outline_rounded,
                                        ),
                                        _buildFieldStack(
                                          controller: _additionalController,
                                          label: 'Additional Business Info',
                                          prefixIcon:
                                              Icons.business_center_rounded,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 36),

                                  // Save changes button
                                  SpringButton(
                                    onTap: state is ProfileUpdating
                                        ? () {}
                                        : () => _onSave(profile),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: state is ProfileUpdating
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                'Save Changes',
                                                style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.5,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  // Delete Account Button
                                  OutlinedButton(
                                    onPressed: _showDeleteConfirmation,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red.shade600,
                                      side: BorderSide(
                                          color: Colors.red.shade600),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Delete Account',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
