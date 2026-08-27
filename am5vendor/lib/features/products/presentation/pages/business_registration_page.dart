import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/onboarding_session_guard.dart';
import '../../../../core/utils/image_upload_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../data/models/product_model.dart';
import '../../../auth/presentation/bloc/business_registration_bloc/business_registration_bloc.dart';
import '../../../auth/presentation/bloc/business_registration_bloc/business_registration_event.dart';
import '../../../auth/presentation/bloc/business_registration_bloc/business_registration_state.dart';

class BusinessRegistrationPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String businessName;
  final bool isSingleService;
  final int mainCategoryId;
  final String mainCategoryName;
  final List<SubCategoryItem> selectedSubCategories;
  final List<SubSubCategoryItem> selectedServiceTypes;

  const BusinessRegistrationPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.businessName,
    required this.isSingleService,
    this.mainCategoryId = 1,
    this.mainCategoryName = 'Home Services',
    this.selectedSubCategories = const [],
    this.selectedServiceTypes = const [],
  });

  @override
  State<BusinessRegistrationPage> createState() =>
      _BusinessRegistrationPageState();
}

class _BusinessRegistrationPageState extends State<BusinessRegistrationPage> {
  int _currentStep = 0; // 0: Details & Uploads, 1: Policies, 2: Certificate

  // Paths
  String? _faceVideoPath;
  String? _aadharFrontPath;
  String? _aadharBackPath;
  String? _panFrontPath;
  String? _panBackPath;
  String? _addressProofPath;
  String? _businessDocPath; // Also used for GST Document
  String? _msmeDocPath;
  String? _govtAuthDocPath;
  String? _currentBillDocPath;

  // Controllers
  final _gstController = TextEditingController();
  final _panController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _uscNumberController = TextEditingController();
  final _msmeController = TextEditingController();
  final _govtAuthDocNumberController = TextEditingController();
  final _currentBillNumberController = TextEditingController();

  final Map<String, String> _existingDocUrls = {};
  bool _isLoadingDetails = true;
  bool _kycLocked = false;

  @override
  void initState() {
    super.initState();
    _aadhaarController.addListener(_onAadhaarChanged);
    _fetchBusinessDetails();
  }

  Future<void> _fetchBusinessDetails() async {
    try {
      final dio = di.sl<Dio>();
      final response = await dio.get('/vendors/me/business-details');
      if (response.statusCode == 200 && mounted) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _gstController.text = data['gst_number']?.toString() ?? '';
          _panController.text = data['pan_number']?.toString() ?? '';
          _aadhaarController.text = data['aadhaar_number']?.toString() ?? '';
          _uscNumberController.text = data['usc_number']?.toString() ?? '';
          _msmeController.text = data['msme_number']?.toString() ?? '';
          _govtAuthDocNumberController.text =
              data['govt_auth_doc_number']?.toString() ?? '';
          _currentBillNumberController.text =
              data['current_bill_number']?.toString() ?? '';

          _existingDocUrls.clear();
          final docs = data['documents'] as List<dynamic>? ?? [];
          for (final doc in docs) {
            if (doc is Map) {
              final type = doc['document_type']?.toString();
              final url = doc['document_url']?.toString();
              if (type != null && url != null && url.isNotEmpty) {
                _existingDocUrls[type] = url;
              }
            }
          }
          _isLoadingDetails = false;
          _kycLocked = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    } catch (e) {
      debugPrint('Failed to fetch business details for prefill: $e');
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  bool _hasDocument(String type, String? localPath) =>
      (localPath != null && localPath.isNotEmpty) ||
      (_existingDocUrls[type]?.isNotEmpty ?? false);

  Map<String, dynamic> _availabilityExtra() => {
        'mainCategoryId': widget.mainCategoryId,
        'mainCategoryName': widget.mainCategoryName,
        'selectedSubCategories': widget.selectedSubCategories,
        'selectedServiceTypes': widget.selectedServiceTypes,
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'businessName': widget.businessName,
        'isSingleService': widget.isSingleService,
      };

  Map<String, dynamic> _registrationExtra() => {
        'mainCategoryId': widget.mainCategoryId,
        'mainCategoryName': widget.mainCategoryName,
        'selectedSubCategories': widget.selectedSubCategories,
        'selectedServiceTypes': widget.selectedServiceTypes,
      };

  void _goToEditServices() {
    context.go('/manage-categories');
  }

  void _goToEditSlots() {
    context.go('/vendor-availability', extra: _availabilityExtra());
  }

  void _goToEditPartnerDetails() {
    context.go('/vendor-registration', extra: _registrationExtra());
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    _goToEditSlots();
  }

  bool get _canEditPreviousSteps =>
      OnboardingSessionGuard.instance.canNavigateBack;

  bool get _canEditServices => OnboardingSessionGuard.instance.canEditServices;

  void _onAadhaarChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _gstController.dispose();
    _panController.dispose();
    _aadhaarController.dispose();
    _uscNumberController.dispose();
    _msmeController.dispose();
    _govtAuthDocNumberController.dispose();
    _currentBillNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument({
    required String title,
    required bool isVideo,
    required Function(String path) onFilePicked,
  }) async {
    if (_kycLocked) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'KYC documents cannot be changed after submission.',
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ImagePicker picker = ImagePicker();

    Future<void> handleImagePick(ImageSource source) async {
      try {
        final photo = await ImageUploadHelper.pickImage(picker, source);
        if (photo != null) {
          onFilePicked(photo.path);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }

    if (kIsWeb) {
      try {
        if (isVideo) {
          final XFile? video =
              await picker.pickVideo(source: ImageSource.gallery);
          if (video != null) {
            onFilePicked(video.path);
          }
        } else {
          await handleImagePick(ImageSource.gallery);
        }
      } catch (e) {
        debugPrint('Web pick failed: $e');
      }
      return;
    }

    Widget buildContent(BuildContext pickerContext) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload $title',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select a source to upload your file',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(8, -8),
                  child: IconButton(
                    icon: Icon(Icons.close_rounded,
                        color:
                            isDark ? Colors.white54 : AppColors.textSecondary),
                    onPressed: () => Navigator.pop(pickerContext),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isVideo) ...[
                  _SourceOptionTile(
                    icon: Icons.videocam_rounded,
                    label: 'Record Video',
                    onTap: () async {
                      Navigator.pop(pickerContext);
                      try {
                        final XFile? video = await picker.pickVideo(
                          source: ImageSource.camera,
                          maxDuration: const Duration(seconds: 10),
                        );
                        if (video != null) {
                          onFilePicked(video.path);
                        }
                      } catch (e) {
                        debugPrint('Record video failed: $e');
                      }
                    },
                  ),
                  _SourceOptionTile(
                    icon: Icons.video_library_rounded,
                    label: 'Choose Video',
                    onTap: () async {
                      Navigator.pop(pickerContext);
                      try {
                        final XFile? video =
                            await picker.pickVideo(source: ImageSource.gallery);
                        if (video != null) {
                          onFilePicked(video.path);
                        }
                      } catch (e) {
                        debugPrint('Choose video failed: $e');
                      }
                    },
                  ),
                ] else ...[
                  _SourceOptionTile(
                    icon: Icons.camera_alt_rounded,
                    label: 'Take Photo',
                    onTap: () async {
                      Navigator.pop(pickerContext);
                      await handleImagePick(ImageSource.camera);
                    },
                  ),
                  _SourceOptionTile(
                    icon: Icons.photo_library_rounded,
                    label: 'Choose Image',
                    onTap: () async {
                      Navigator.pop(pickerContext);
                      await handleImagePick(ImageSource.gallery);
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: buildContent(dialogContext),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool status,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: status
              ? (isDark
                  ? AppColors.success.withValues(alpha: 0.08)
                  : AppColors.successContainer.withValues(alpha: 0.2))
              : (isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.4)
                  : const Color(0xFFF4F8FC)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: status
                ? AppColors.success.withValues(alpha: 0.5)
                : (isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.6)
                    : AppColors.border),
            width: status ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: status
                    ? AppColors.success.withValues(alpha: 0.15)
                    : (isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.1)
                        : AppColors.primaryContainer.withValues(alpha: 0.4)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: status
                    ? AppColors.success
                    : (isDark ? AppColors.accentLight : AppColors.primary),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (status) ...[
              if (onClear != null && !_kycLocked)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 20),
                  tooltip: 'Delete file',
                  onPressed: onClear,
                )
              else
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 20),
            ] else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                    : AppColors.textSecondary.withValues(alpha: 0.6),
                size: 14,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    final errorMsg = validator?.call(controller.text);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly || _kycLocked,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            onChanged: (v) {
              setState(() {});
            },
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              errorText: errorMsg,
              errorMaxLines: 2,
              errorStyle: GoogleFonts.outfit(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: GoogleFonts.outfit(
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                    : AppColors.textHint,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: isDark ? AppColors.accentLight : AppColors.primary,
                size: 20,
              ),
              filled: true,
              fillColor:
                  isDark ? AppColors.darkBackground : const Color(0xFFF4F8FC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.accent : AppColors.primary,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final aadhaarValid =
        FormValidators.validateAadhaar(_aadhaarController.text) == null;
    final panValid = FormValidators.validatePAN(_panController.text) == null;
    final msmeValid = FormValidators.validateMSME(_msmeController.text) == null;
    final uscValid =
        FormValidators.validateUSC(_uscNumberController.text) == null;
    final billValid =
        FormValidators.validateCurrentBill(_currentBillNumberController.text) ==
            null;

    final allFilled = aadhaarValid &&
        panValid &&
        msmeValid &&
        uscValid &&
        billValid &&
        _hasDocument('aadhar_front', _aadharFrontPath) &&
        _hasDocument('aadhar_back', _aadharBackPath);

    return BlocConsumer<BusinessRegistrationBloc, BusinessRegistrationState>(
      listener: (context, state) {
        if (state is BusinessRegistrationSuccess) {
          OnboardingSessionGuard.instance.unlockOnForwardProgress();
          setState(() {
            _currentStep = 1;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!context.mounted) return;
            final result = await context.push<bool>(
              '/subscription',
              extra: {
                'fromOnboarding': true,
                'isSingleService': widget.isSingleService,
                'selectedSubCategories': widget.selectedSubCategories,
              },
            );
            if (result == true && mounted) {
              setState(() {
                _currentStep = 2;
              });
            }
          });
        } else if (state is BusinessRegistrationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        final isDesktop = ResponsiveLayout.isDesktop(context);

        final List<Widget> docWidgets = [];

        docWidgets.addAll([
          _buildUploadButton(
            title: 'Aadhaar Card (Front)',
            subtitle: 'Clear image of front side',
            icon: Icons.contact_page_rounded,
            status: _hasDocument('aadhar_front', _aadharFrontPath),
            onTap: () => _pickDocument(
              title: 'Aadhaar Front',
              isVideo: false,
              onFilePicked: (path) => setState(() {
                _aadharFrontPath = path;
                _existingDocUrls.remove('aadhar_front');
              }),
            ),
            onClear: () => setState(() {
              _aadharFrontPath = null;
              _existingDocUrls.remove('aadhar_front');
            }),
          ),
          _buildUploadButton(
            title: 'Aadhaar Card (Back)',
            subtitle: 'Clear image of back side',
            icon: Icons.contact_page_rounded,
            status: _hasDocument('aadhar_back', _aadharBackPath),
            onTap: () => _pickDocument(
              title: 'Aadhaar Back',
              isVideo: false,
              onFilePicked: (path) => setState(() {
                _aadharBackPath = path;
                _existingDocUrls.remove('aadhar_back');
              }),
            ),
            onClear: () => setState(() {
              _aadharBackPath = null;
              _existingDocUrls.remove('aadhar_back');
            }),
          ),
        ]);

        if (widget.isSingleService) {
          docWidgets.addAll([
            _buildUploadButton(
              title: 'PAN Card (Front) (Optional)',
              subtitle: 'Clear image of PAN card',
              icon: Icons.credit_card_rounded,
              status: _panFrontPath != null,
              onTap: () => _pickDocument(
                title: 'PAN Front',
                isVideo: false,
                onFilePicked: (path) => setState(() => _panFrontPath = path),
              ),
              onClear: () => setState(() => _panFrontPath = null),
            ),
            _buildUploadButton(
              title: 'PAN Card (Back) (Optional)',
              subtitle: 'Clear image of PAN card back',
              icon: Icons.credit_card_rounded,
              status: _panBackPath != null,
              onTap: () => _pickDocument(
                title: 'PAN Back',
                isVideo: false,
                onFilePicked: (path) => setState(() => _panBackPath = path),
              ),
              onClear: () => setState(() => _panBackPath = null),
            ),
            _buildUploadButton(
              title: 'Current Bill Document (Optional)',
              subtitle: 'Upload business current bill',
              icon: Icons.receipt_long_rounded,
              status: _currentBillDocPath != null,
              onTap: () => _pickDocument(
                title: 'Current Bill Document',
                isVideo: false,
                onFilePicked: (path) =>
                    setState(() => _currentBillDocPath = path),
              ),
              onClear: () => setState(() => _currentBillDocPath = null),
            ),
          ]);
        }
        docWidgets.addAll([
          _buildUploadButton(
            title: 'Any other Govt Authorized Business proof (Optional)',
            subtitle: 'Valid business govt authorized document',
            icon: Icons.gavel_rounded,
            status: _govtAuthDocPath != null,
            onTap: () => _pickDocument(
              title: 'Any other Govt Authorized Business proof',
              isVideo: false,
              onFilePicked: (path) => setState(() => _govtAuthDocPath = path),
            ),
            onClear: () => setState(() => _govtAuthDocPath = null),
          ),
          _buildUploadButton(
            title: 'MSME Document (Optional)',
            subtitle: 'Upload MSME Registration',
            icon: Icons.description_rounded,
            status: _msmeDocPath != null,
            onTap: () => _pickDocument(
              title: 'MSME Document',
              isVideo: false,
              onFilePicked: (path) => setState(() => _msmeDocPath = path),
            ),
            onClear: () => setState(() => _msmeDocPath = null),
          ),
          _buildUploadButton(
            title: 'Face Verification Video (Optional)',
            subtitle: 'Record a short 5s video of your face',
            icon: Icons.videocam_rounded,
            status: _faceVideoPath != null,
            onTap: () => _pickDocument(
              title: 'Face Video',
              isVideo: true,
              onFilePicked: (path) => setState(() => _faceVideoPath = path),
            ),
            onClear: () => setState(() => _faceVideoPath = null),
          ),
          _buildUploadButton(
            title: 'Address Proof (Optional)',
            subtitle: 'Upload valid address proof (e.g., Utility bill)',
            icon: Icons.home_rounded,
            status: _addressProofPath != null,
            onTap: () => _pickDocument(
              title: 'Address Proof',
              isVideo: false,
              onFilePicked: (path) => setState(() => _addressProofPath = path),
            ),
            onClear: () => setState(() => _addressProofPath = null),
          ),
        ]);
        if (!widget.isSingleService) {
          docWidgets.add(
            _buildUploadButton(
              title: 'GST Document (Optional)',
              subtitle: 'Upload valid GST registration proof',
              icon: Icons.storefront_rounded,
              status: _businessDocPath != null,
              onTap: () => _pickDocument(
                title: 'GST Document',
                isVideo: false,
                onFilePicked: (path) => setState(() => _businessDocPath = path),
              ),
              onClear: () => setState(() => _businessDocPath = null),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_canEditPreviousSteps) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _goToEditSlots,
                      icon: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text(
                        'Edit Hours',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _goToEditPartnerDetails,
                      icon: const Icon(Icons.person_outline_rounded, size: 18),
                      label: Text(
                        'Edit Details',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              Text(
                'Complete payment to finish activation.',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            if (_kycLocked) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'KYC documents have been submitted and are locked for review. '
                        'You can view your details but cannot change them.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Business & Identity Details',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (!widget.isSingleService) ...[
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextInput(
                        controller: _gstController,
                        label: 'GST Number (Optional)',
                        hint: 'Enter GST Number',
                        icon: Icons.business_rounded,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildTextInput(
                        controller: _msmeController,
                        label: 'MSME Number (Optional)',
                        hint: 'e.g. UDYAM-AP-12-1234567',
                        icon: Icons.confirmation_number_rounded,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9\-]')),
                          TextInputFormatter.withFunction((old, updated) {
                            return updated.copyWith(
                                text: updated.text.toUpperCase());
                          }),
                        ],
                        validator: FormValidators.validateMSME,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextInput(
                        controller: _govtAuthDocNumberController,
                        label:
                            'Any other Govt Authorized Business proof (Optional)',
                        hint: 'Enter Doc Number',
                        icon: Icons.document_scanner_rounded,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildTextInput(
                        controller: _aadhaarController,
                        label: 'Aadhaar Number *',
                        hint: 'Enter 12-digit Aadhaar',
                        icon: Icons.fingerprint_rounded,
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: FormValidators.validateAadhaar,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildTextInput(
                  controller: _gstController,
                  label: 'GST Number (Optional)',
                  hint: 'Enter GST Number',
                  icon: Icons.business_rounded,
                ),
                _buildTextInput(
                  controller: _msmeController,
                  label: 'MSME Number (Optional)',
                  hint: 'e.g. UDYAM-AP-12-1234567',
                  icon: Icons.confirmation_number_rounded,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                    TextInputFormatter.withFunction((old, updated) {
                      return updated.copyWith(text: updated.text.toUpperCase());
                    }),
                  ],
                  validator: FormValidators.validateMSME,
                ),
                _buildTextInput(
                  controller: _govtAuthDocNumberController,
                  label: 'Any other Govt Authorized Business proof (Optional)',
                  hint: 'Enter Doc Number',
                  icon: Icons.document_scanner_rounded,
                ),
                _buildTextInput(
                  controller: _aadhaarController,
                  label: 'Aadhaar Number *',
                  hint: 'Enter 12-digit Aadhaar',
                  icon: Icons.fingerprint_rounded,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: FormValidators.validateAadhaar,
                ),
              ],
            ] else ...[
              if (isDesktop) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextInput(
                        controller: _panController,
                        label: 'PAN Number (Optional)',
                        hint: 'e.g. ABCDE1234F',
                        icon: Icons.credit_card_rounded,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9]')),
                          TextInputFormatter.withFunction((old, updated) {
                            return updated.copyWith(
                                text: updated.text.toUpperCase());
                          }),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: FormValidators.validatePAN,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildTextInput(
                        controller: _aadhaarController,
                        label: 'Aadhaar Number *',
                        hint: 'Enter 12-digit Aadhaar',
                        icon: Icons.fingerprint_rounded,
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: FormValidators.validateAadhaar,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextInput(
                        controller: _msmeController,
                        label: 'MSME Number (Optional)',
                        hint: 'e.g. UDYAM-AP-12-1234567',
                        icon: Icons.confirmation_number_rounded,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9\-]')),
                          TextInputFormatter.withFunction((old, updated) {
                            return updated.copyWith(
                                text: updated.text.toUpperCase());
                          }),
                        ],
                        validator: FormValidators.validateMSME,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildTextInput(
                        controller: _uscNumberController,
                        label: 'USC Number (Optional)',
                        hint: 'Enter USC Address Identifier',
                        icon: Icons.location_on_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: FormValidators.validateUSC,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextInput(
                        controller: _currentBillNumberController,
                        label: 'Current Bill Number (Optional)',
                        hint: 'Enter Current Bill Number',
                        icon: Icons.receipt_rounded,
                        validator: FormValidators.validateCurrentBill,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildTextInput(
                        controller: _govtAuthDocNumberController,
                        label:
                            'Any other Govt Authorized Business proof (Optional)',
                        hint: 'Enter Doc Number',
                        icon: Icons.document_scanner_rounded,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _buildTextInput(
                  controller: _panController,
                  label: 'PAN Number (Optional)',
                  hint: 'e.g. ABCDE1234F',
                  icon: Icons.credit_card_rounded,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    TextInputFormatter.withFunction((old, updated) {
                      return updated.copyWith(text: updated.text.toUpperCase());
                    }),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: FormValidators.validatePAN,
                ),
                _buildTextInput(
                  controller: _aadhaarController,
                  label: 'Aadhaar Number *',
                  hint: 'Enter 12-digit Aadhaar',
                  icon: Icons.fingerprint_rounded,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: FormValidators.validateAadhaar,
                ),
                _buildTextInput(
                  controller: _msmeController,
                  label: 'MSME Number (Optional)',
                  hint: 'e.g. UDYAM-AP-12-1234567',
                  icon: Icons.confirmation_number_rounded,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                    TextInputFormatter.withFunction((old, updated) {
                      return updated.copyWith(text: updated.text.toUpperCase());
                    }),
                  ],
                  validator: FormValidators.validateMSME,
                ),
                _buildTextInput(
                  controller: _uscNumberController,
                  label: 'USC Number (Optional)',
                  hint: 'Enter USC Address Identifier',
                  icon: Icons.location_on_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: FormValidators.validateUSC,
                ),
                _buildTextInput(
                  controller: _currentBillNumberController,
                  label: 'Current Bill Number (Optional)',
                  hint: 'Enter Current Bill Number',
                  icon: Icons.receipt_rounded,
                  validator: FormValidators.validateCurrentBill,
                ),
                _buildTextInput(
                  controller: _govtAuthDocNumberController,
                  label: 'Any other Govt Authorized Business proof (Optional)',
                  hint: 'Enter Doc Number',
                  icon: Icons.document_scanner_rounded,
                ),
              ],
            ],
            const SizedBox(height: 8),
            Text(
              'Required Documents',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (isDesktop)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 80,
                ),
                itemCount: docWidgets.length,
                itemBuilder: (context, index) => docWidgets[index],
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docWidgets.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) => docWidgets[index],
              ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                gradient: allFilled ? AppColors.primaryGradient : null,
                color: allFilled
                    ? null
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: allFilled && state is! BusinessRegistrationLoading
                    ? () {
                        if (_kycLocked) {
                          OnboardingSessionGuard.instance
                              .unlockOnForwardProgress();
                          setState(() => _currentStep = 1);
                          return;
                        }
                        debugPrint(
                            'BusinessRegistrationPage: Submit details clicked.');
                        debugPrint('allFilled: $allFilled, state: $state');
                        debugPrint(
                            'GST: ${_gstController.text}, PAN: ${_panController.text}, Aadhaar: ${_aadhaarController.text}, USC: ${_uscNumberController.text}');
                        debugPrint(
                            'Files: aadharFront=$_aadharFrontPath, aadharBack=$_aadharBackPath, panFront=$_panFrontPath, panBack=$_panBackPath, faceVideo=$_faceVideoPath');
                        context.read<BusinessRegistrationBloc>().add(
                              SubmitBusinessDetailsEvent(
                                gstNumber: _gstController.text,
                                panNumber: _panController.text,
                                aadhaarNumber: _aadhaarController.text,
                                msmeNumber: _msmeController.text,
                                govtAuthDocNumber:
                                    _govtAuthDocNumberController.text,
                                currentBillNumber:
                                    _currentBillNumberController.text,
                                aadharFrontPath: _aadharFrontPath,
                                aadharBackPath: _aadharBackPath,
                                panFrontPath: _panFrontPath,
                                panBackPath: _panBackPath,
                                faceVideoPath: _faceVideoPath,
                                addressProofPath: _addressProofPath,
                                businessDocPath: _businessDocPath,
                                msmeDocPath: _msmeDocPath,
                                govtAuthDocPath: _govtAuthDocPath,
                                currentBillDocPath: _currentBillDocPath,
                                existingDocumentUrls: Map<String, String>.from(
                                  _existingDocUrls,
                                ),
                              ),
                            );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: state is BusinessRegistrationLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        _kycLocked ? 'CONTINUE' : 'SUBMIT DETAILS',
                        style: GoogleFonts.outfit(
                          color: allFilled
                              ? Colors.white
                              : (isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade600),
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubscriptionPromptStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.primary)
                      .withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.stars_rounded,
              color: isDark ? AppColors.accentLight : AppColors.primary,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Activate Your Business Account',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your business registration details have been submitted successfully. To activate your partner account and start receiving customer leads, please complete the subscription registration.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () async {
              final result = await context.push<bool>(
                '/subscription',
                extra: {'fromOnboarding': true},
              );
              if (result == true) {
                setState(() {
                  _currentStep = 2;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Center(
              child: Text(
                'PROCEED TO SUBSCRIPTION',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = widget.isSingleService
        ? '${widget.firstName} ${widget.lastName}'
        : widget.businessName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withValues(alpha: 0.15),
                AppColors.success.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded,
                    color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Registration Completed Successfully!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162239) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent, width: 2.5),
          ),
          child: Column(
            children: [
              Text(
                'CERTIFICATE OF REGISTRATION',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'This is to certify that',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentLight : AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'has been successfully verified and registered as an authorized partner with AM5ROYAL Company.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 11.5,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton(
            onPressed: () async {
              final prefs = di.sl<SharedPreferences>();
              await prefs.setBool('business_verification_completed', true);
              if (!mounted) return;
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Center(
              child: Text(
                'GO TO HOME DASHBOARD',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final maxWidth = isDesktop ? 960.0 : 680.0;

    return PopScope(
      canPop: _canEditPreviousSteps && _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _canEditPreviousSteps) _handleBack();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        appBar: AppBar(
          title: Text(
            'Business Verification',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.primary,
            ),
            onPressed: _handleBack,
          ),
        ),
        body: BlocProvider(
          create: (context) => di.sl<BusinessRegistrationBloc>(),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/water.png',
                  fit: BoxFit.cover,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.15 : 0.85),
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
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isLoadingDetails
                                ? const Padding(
                                    key: ValueKey('loading'),
                                    padding: EdgeInsets.all(48),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : ClipRRect(
                                    key: ValueKey<int>(_currentStep),
                                    borderRadius: BorderRadius.circular(28),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 16.0, sigmaY: 16.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF131F35)
                                                  .withValues(alpha: 0.65)
                                              : Colors.white
                                                  .withValues(alpha: 0.75),
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.08)
                                                : Colors.white
                                                    .withValues(alpha: 0.5),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                  alpha: isDark ? 0.25 : 0.05),
                                              blurRadius: 24,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(24),
                                        child: _currentStep == 0
                                            ? _buildDetailsStep()
                                            : _currentStep == 1
                                                ? _buildSubscriptionPromptStep()
                                                : _buildCertificateStep(),
                                      ),
                                    ),
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
        ),
      ),
    );
  }
}

class _SourceOptionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SourceOptionTile> createState() => _SourceOptionTileState();
}

class _SourceOptionTileState extends State<_SourceOptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark ? AppColors.accentLight : AppColors.primary;
    final defaultBg =
        isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC);
    final hoverBg = isDark ? const Color(0xFF384252) : const Color(0xFFEFF6FF);
    final defaultBorder = isDark ? AppColors.darkBorder : AppColors.border;
    final hoverBorder = isDark ? AppColors.accent : AppColors.primary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 130,
          decoration: BoxDecoration(
            color: _isHovered ? hoverBg : defaultBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? hoverBorder : defaultBorder,
              width: _isHovered ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: _isHovered ? 0.35 : 0.15)
                    : primaryColor.withValues(alpha: _isHovered ? 0.12 : 0.04),
                blurRadius: _isHovered ? 16 : 8,
                offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: primaryColor.withValues(alpha: 0.1),
              highlightColor: primaryColor.withValues(alpha: 0.05),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? primaryColor.withValues(alpha: 0.15)
                            : primaryColor.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: primaryColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
