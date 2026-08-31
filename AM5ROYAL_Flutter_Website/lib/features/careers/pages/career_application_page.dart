import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../data/careers_api.dart';
import '../utils/career_form_validators.dart';

class CareerApplicationPage extends StatefulWidget {
  const CareerApplicationPage({
    super.key,
    required this.opening,
  });

  final JobOpening opening;

  @override
  State<CareerApplicationPage> createState() => _CareerApplicationPageState();
}

class _CareerApplicationPageState extends State<CareerApplicationPage> {
  final CareersApi _api = CareersApi();
  final _formKey = GlobalKey<FormState>();
  final _resumeFormKey = GlobalKey<FormState>();

  int _step = 0;
  bool _isSubmitting = false;
  String? _applicationReference;
  String? _resumeError;
  AutovalidateMode _detailsAutovalidateMode = AutovalidateMode.disabled;
  AutovalidateMode _resumeAutovalidateMode = AutovalidateMode.disabled;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _coverLetterController = TextEditingController();

  String? _location;
  String? _experience;
  String? _noticePeriod;
  ResumeUploadResult? _resume;
  bool _isUploadingResume = false;

  static const _locations = [
    'Mumbai',
    'Delhi NCR',
    'Bengaluru',
    'Hyderabad',
    'Chennai',
    'Pune',
    'Kolkata',
    'Ahmedabad',
    'Jaipur',
    'Other',
  ];

  static const _experienceOptions = [
    'Fresher',
    '0-1 Years',
    '1-2 Years',
    '2-3 Years',
    '3-5 Years',
    '5+ Years',
  ];

  static const _noticeOptions = [
    'Immediate',
    '15 Days',
    '30 Days',
    '45 Days',
    '60 Days',
    '90 Days',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: CareerFormValidators.allowedResumeExtensions
          .toList(growable: false),
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() {
        _resumeError = 'Could not read the selected file. Please try again.';
        _resume = null;
      });
      return;
    }

    final validationError = CareerFormValidators.resumeFile(
      fileName: file.name,
      fileSize: bytes.length,
    );
    if (validationError != null) {
      setState(() {
        _resumeError = validationError;
        _resume = null;
      });
      return;
    }

    setState(() {
      _isUploadingResume = true;
      _resumeError = null;
    });
    try {
      final uploaded = await _api.uploadResume(
        bytes: bytes,
        fileName: file.name,
      );
      if (!mounted) return;
      setState(() {
        _resume = uploaded;
        _resumeError = null;
      });
    } catch (e) {
      setState(() {
        _resume = null;
        _resumeError = 'Failed to upload resume. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isUploadingResume = false);
    }
  }

  bool _validateDetailsStep() {
    setState(() => _detailsAutovalidateMode = AutovalidateMode.always);
    return _formKey.currentState?.validate() ?? false;
  }

  bool _validateResumeStep() {
    setState(() => _resumeAutovalidateMode = AutovalidateMode.always);

    final String? resumeValidation =
        CareerFormValidators.resumeRequired(_resume);
    final bool coverLetterValid =
        _resumeFormKey.currentState?.validate() ?? true;

    if (resumeValidation != null) {
      setState(() => _resumeError = resumeValidation);
      return false;
    }

    return coverLetterValid;
  }

  Future<void> _submit() async {
    if (!_validateResumeStep()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final ref = await _api.submitApplication(
        jobOpeningId: widget.opening.id,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: CareerFormValidators.normalizedPhone(_phoneController.text),
        currentLocation: _location!,
        totalExperience: _experience!,
        noticePeriod: _noticePeriod!,
        resumeUrl: _resume!.url,
        resumeFileName: _resume!.fileName,
        resumeFileSize: _resume!.fileSize,
        coverLetter: _coverLetterController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _applicationReference = ref;
        _step = 4;
      });
    } catch (e) {
      _showError('Failed to submit application: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _nextStep() {
    if (_step == 1) {
      if (!_validateDetailsStep()) {
        return;
      }
    }
    if (_step == 2) {
      if (!_validateResumeStep()) {
        return;
      }
    }
    setState(() => _step += 1);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.opening.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepIndicator(currentStep: _step),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildStepContent(isDesktop),
                ),
                if (_step < 4) ...[
                  const SizedBox(height: 24),
                  _buildActions(),
                ],
                const SizedBox(height: 32),
                _TrustFooter(isDesktop: isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isDesktop) {
    switch (_step) {
      case 0:
        return _RoleDetailsStep(opening: widget.opening);
      case 1:
        return _DetailsFormStep(
          formKey: _formKey,
          autovalidateMode: _detailsAutovalidateMode,
          nameController: _nameController,
          emailController: _emailController,
          phoneController: _phoneController,
          location: _location,
          experience: _experience,
          noticePeriod: _noticePeriod,
          locations: _locations,
          experienceOptions: _experienceOptions,
          noticeOptions: _noticeOptions,
          onLocationChanged: (v) => setState(() => _location = v),
          onExperienceChanged: (v) => setState(() => _experience = v),
          onNoticeChanged: (v) => setState(() => _noticePeriod = v),
        );
      case 2:
        return _ResumeStep(
          formKey: _resumeFormKey,
          autovalidateMode: _resumeAutovalidateMode,
          resume: _resume,
          resumeError: _resumeError,
          isUploading: _isUploadingResume,
          coverLetterController: _coverLetterController,
          onPickResume: _pickResume,
          onRemoveResume: () => setState(() {
            _resume = null;
            _resumeError = 'Please upload your resume to continue';
          }),
        );
      case 3:
        return _ReviewStep(
          opening: widget.opening,
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          location: _location ?? '',
          experience: _experience ?? '',
          noticePeriod: _noticePeriod ?? '',
          resume: _resume,
          coverLetter: _coverLetterController.text.trim(),
        );
      default:
        return _SuccessStep(
          applicationReference: _applicationReference ?? '',
          onBack: () => Navigator.of(context).pop(),
        );
    }
  }

  Widget _buildActions() {
    return Row(
      children: [
        if (_step > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => setState(() => _step -= 1),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.royalBlue),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    if (_step == 0) {
                      setState(() => _step = 1);
                    } else if (_step == 3) {
                      _submit();
                    } else {
                      _nextStep();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_step == 0
                    ? 'Apply for this Role'
                    : _step == 3
                        ? 'Submit Application'
                        : 'Save & Continue'),
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  static const _labels = [
    'Choose Role',
    'Fill Details',
    'Upload Resume',
    'Review & Submit',
    'Submitted',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(_labels.length, (index) {
            final active = index <= currentStep;
            final isLast = index == _labels.length - 1;
            return Expanded(
              child: Row(
                children: [
                  _StepDot(number: index + 1, active: active),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < currentStep
                            ? AppColors.royalBlue
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _labels[currentStep.clamp(0, _labels.length - 1)],
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.number, required this.active});

  final int number;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.royalBlue : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF64748B),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RoleDetailsStep extends StatelessWidget {
  const _RoleDetailsStep({required this.opening});

  final JobOpening opening;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            opening.title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.work_outline, label: opening.employmentType),
              _MetaChip(icon: Icons.location_on_outlined, label: opening.location),
              _MetaChip(icon: Icons.timeline, label: opening.experienceYears),
              _MetaChip(icon: Icons.apartment_outlined, label: opening.department),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Job Description',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            opening.description,
            style: const TextStyle(color: Color(0xFF475569), height: 1.6),
          ),
          const SizedBox(height: 20),
          const Text(
            'Key Skills',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opening.keySkills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    backgroundColor: const Color(0x0D0B4EA2),
                    labelStyle: const TextStyle(
                      color: AppColors.royalBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DetailsFormStep extends StatelessWidget {
  const _DetailsFormStep({
    required this.formKey,
    required this.autovalidateMode,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.location,
    required this.experience,
    required this.noticePeriod,
    required this.locations,
    required this.experienceOptions,
    required this.noticeOptions,
    required this.onLocationChanged,
    required this.onExperienceChanged,
    required this.onNoticeChanged,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String? location;
  final String? experience;
  final String? noticePeriod;
  final List<String> locations;
  final List<String> experienceOptions;
  final List<String> noticeOptions;
  final ValueChanged<String?> onLocationChanged;
  final ValueChanged<String?> onExperienceChanged;
  final ValueChanged<String?> onNoticeChanged;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Form(
        key: formKey,
        autovalidateMode: autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'All fields marked with * are required',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 20),
            _TextField(
              controller: nameController,
              label: 'Full Name *',
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                LengthLimitingTextInputFormatter(200),
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s.'-]")),
              ],
              validator: CareerFormValidators.fullName,
            ),
            const SizedBox(height: 14),
            _TextField(
              controller: emailController,
              label: 'Email Address *',
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                LengthLimitingTextInputFormatter(200),
              ],
              validator: CareerFormValidators.email,
            ),
            const SizedBox(height: 14),
            _TextField(
              controller: phoneController,
              label: 'Phone Number *',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: CareerFormValidators.phone,
            ),
            const SizedBox(height: 14),
            _DropdownField(
              label: 'Current Location *',
              value: location,
              items: locations,
              onChanged: onLocationChanged,
              validator: (v) =>
                  CareerFormValidators.requiredSelection(v, 'current location'),
            ),
            const SizedBox(height: 14),
            _DropdownField(
              label: 'Total Experience (Years) *',
              value: experience,
              items: experienceOptions,
              onChanged: onExperienceChanged,
              validator: (v) =>
                  CareerFormValidators.requiredSelection(v, 'total experience'),
            ),
            const SizedBox(height: 14),
            _DropdownField(
              label: 'Notice Period *',
              value: noticePeriod,
              items: noticeOptions,
              onChanged: onNoticeChanged,
              validator: (v) =>
                  CareerFormValidators.requiredSelection(v, 'notice period'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeStep extends StatelessWidget {
  const _ResumeStep({
    required this.formKey,
    required this.autovalidateMode,
    required this.resume,
    required this.resumeError,
    required this.isUploading,
    required this.coverLetterController,
    required this.onPickResume,
    required this.onRemoveResume,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  final ResumeUploadResult? resume;
  final String? resumeError;
  final bool isUploading;
  final TextEditingController coverLetterController;
  final VoidCallback onPickResume;
  final VoidCallback onRemoveResume;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Form(
        key: formKey,
        autovalidateMode: autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Resume *',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: isUploading ? null : onPickResume,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: resumeError != null
                        ? Colors.red.shade400
                        : const Color(0xFF94A3B8),
                    width: 1.5,
                  ),
                  color: const Color(0xFFF8FAFC),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: isUploading ? Colors.grey : AppColors.royalBlue,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isUploading
                          ? 'Uploading...'
                          : 'Drag & drop or click to upload',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'PDF, DOC, DOCX (Max 5MB)',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            if (resumeError != null) ...[
              const SizedBox(height: 8),
              Text(
                resumeError!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          if (resume != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: AppColors.royalBlue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resume!.fileName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(resume!.fileSize / 1024).toStringAsFixed(1)} KB',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onRemoveResume,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'Cover Letter (Optional)',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: coverLetterController,
            maxLines: 5,
            maxLength: CareerFormValidators.maxCoverLetterLength,
            validator: CareerFormValidators.coverLetter,
            decoration: InputDecoration(
              hintText: 'Tell us why you are a great fit...',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              counterText:
                  'Optional • min 20 characters if you add a cover letter',
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.opening,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.experience,
    required this.noticePeriod,
    required this.resume,
    required this.coverLetter,
  });

  final JobOpening opening;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String experience;
  final String noticePeriod;
  final ResumeUploadResult? resume;
  final String coverLetter;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review & Submit',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          _ReviewSection(
            title: 'Personal Details',
            rows: {
              'Name': fullName,
              'Email': email,
              'Phone': phone,
              'Location': location,
              'Experience': experience,
              'Notice Period': noticePeriod,
            },
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Applied Role',
            rows: {
              'Job Title': opening.title,
              'Department': opening.department,
              'Employment Type': opening.employmentType,
              'Location': opening.location,
            },
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Resume',
            rows: {
              'File': resume?.fileName ?? '—',
            },
          ),
          if (coverLetter.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ReviewSection(
              title: 'Cover Letter',
              rows: {'': coverLetter},
            ),
          ],
        ],
      ),
    );
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({
    required this.applicationReference,
    required this.onBack,
  });

  final String applicationReference;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF16A34A),
              size: 42,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Application Submitted Successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Application ID: $applicationReference',
            style: const TextStyle(
              color: AppColors.royalBlue,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              side: const BorderSide(color: AppColors.royalBlue),
            ),
            child: const Text('Back to Open Positions'),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0B1F3A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.royalBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        errorMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        errorMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.title, required this.rows});

  final String title;
  final Map<String, String> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...rows.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: e.key.isEmpty
                  ? Text(e.value, style: const TextStyle(color: Color(0xFF475569)))
                  : RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
                        children: [
                          TextSpan(
                            text: '${e.key}: ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: e.value),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.security_rounded,
        'Secure & Trusted',
        'Your data is encrypted and handled securely.',
      ),
      (
        Icons.insert_drive_file_outlined,
        'Supported Formats',
        'PDF, DOC, and DOCX resumes up to 5MB.',
      ),
      (
        Icons.notifications_active_outlined,
        'Stay Updated',
        'Our HR team will contact shortlisted candidates.',
      ),
    ];

    return Column(
      children: [
        if (isDesktop)
          Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: _TrustItem(
                      icon: item.$1,
                      title: item.$2,
                      subtitle: item.$3,
                    ),
                  ),
                )
                .toList(),
          )
        else
          Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TrustItem(
                      icon: item.$1,
                      title: item.$2,
                      subtitle: item.$3,
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Questions? Contact HR at hr@am5royal.com or +91 98765 43210',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icon, color: AppColors.royalBlue),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
