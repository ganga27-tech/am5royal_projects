import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../bloc/profile/employee_profile_bloc.dart';
import '../bloc/profile/employee_profile_event.dart';
import '../bloc/profile/employee_profile_state.dart';
import '../../data/models/employee_profile_model.dart';

class EditProfileDialog extends StatefulWidget {
  final EmployeeProfileModel profile;

  const EditProfileDialog({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountController;
  late TextEditingController _bankHolderController;
  late TextEditingController _bankIfscController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _bankNameController = TextEditingController(text: widget.profile.bankName ?? '');
    _bankAccountController = TextEditingController(text: widget.profile.bankAccountNumber ?? '');
    _bankHolderController = TextEditingController(text: widget.profile.bankAccountName ?? '');
    _bankIfscController = TextEditingController(text: widget.profile.bankIfscCode ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankHolderController.dispose();
    _bankIfscController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        style: GoogleFonts.inter(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontSize: 13),
          filled: true,
          fillColor: isDark ? AppColors.darkBackground : AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? AppColors.accentLight : AppColors.primary),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: GoogleFonts.inter(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: GoogleFonts.inter(
                        color: isDark ? AppColors.accentLight : AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('First Name', _firstNameController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Last Name', _lastNameController)),
                      ],
                    ),
                    _buildTextField('Email', _emailController),
                    _buildTextField('Phone Number', _phoneController),
                    const SizedBox(height: 24),
                    Text(
                      'Bank Details',
                      style: GoogleFonts.inter(
                        color: isDark ? AppColors.accentLight : AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('Bank Name', _bankNameController),
                    _buildTextField('Account Holder Name', _bankHolderController),
                    _buildTextField('Account Number', _bankAccountController),
                    _buildTextField('IFSC Code', _bankIfscController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            BlocConsumer<EmployeeProfileBloc, EmployeeProfileState>(
              listener: (context, state) {
                if (state is EmployeeProfileUpdateSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
                  );
                  Navigator.pop(context, true);
                } else if (state is EmployeeProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is EmployeeProfileLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final updatedProfile = EmployeeProfileModel(
                              id: widget.profile.id,
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              email: _emailController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              role: widget.profile.role,
                              status: widget.profile.status,
                              referralPoints: widget.profile.referralPoints,
                              bankName: _bankNameController.text.trim(),
                              bankAccountNumber: _bankAccountController.text.trim(),
                              bankAccountName: _bankHolderController.text.trim(),
                              bankIfscCode: _bankIfscController.text.trim(),
                            );
                            context.read<EmployeeProfileBloc>().add(UpdateEmployeeProfile(updatedProfile));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
