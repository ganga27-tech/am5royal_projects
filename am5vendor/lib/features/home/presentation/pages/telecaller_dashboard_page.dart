import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/auth_storage_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../../../features/admin/presentation/bloc/admin_event.dart';
import '../../../../features/admin/presentation/bloc/admin_state.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/employee_api_service.dart';
import '../../data/models/telecaller_onboarded_vendor_model.dart';
import '../../data/models/employee_profile_model.dart';
import '../bloc/profile/employee_profile_bloc.dart';
import '../bloc/profile/employee_profile_event.dart';
import '../bloc/profile/employee_profile_state.dart';
import '../widgets/edit_profile_dialog.dart';
import '../../../../core/widgets/app_network_image.dart';

class TelecallerDashboardPage extends StatefulWidget {
  const TelecallerDashboardPage({super.key});

  @override
  State<TelecallerDashboardPage> createState() =>
      _TelecallerDashboardPageState();
}

class _TelecallerDashboardPageState extends State<TelecallerDashboardPage> {
  int _activeMenuIndex = 0;
  bool _isHoveredLogout = false;

  // Pipeline State
  String _selectedPipelineTab = 'New'; // 'New' | 'Follow-up' | 'Not Interested'

  // Dialog / Form Controllers
  final TextEditingController _vendorNameController = TextEditingController();
  final TextEditingController _vendorPhoneController = TextEditingController();

  final TextEditingController _invitePhoneController = TextEditingController();
  final TextEditingController _companyLeadsSearchController =
      TextEditingController();
  String _companyLeadsStatusFilter = 'All';
  DateTime? _companyLeadsStartDate;
  DateTime? _companyLeadsEndDate;

  String _selectedCategory = 'Home Cleaning';

  // Sticky Local State Databases
  final List<Map<String, dynamic>> _leads = [
    {
      'id': 'l1',
      'name': 'Ramesh Kumar',
      'phone': '+91 9988776655',
      'category': 'Home Cleaning',
      'status': 'New',
      'note': 'Wants to register next week.',
      'lastCalled': '2026-06-18',
    },
    {
      'id': 'l2',
      'name': 'Vikram Mehra',
      'phone': '+91 8877665544',
      'category': 'Plumbing',
      'status': 'Follow-up',
      'note': 'Busy during noon. Call back after 6 PM.',
      'lastCalled': '2026-06-19',
    },
    {
      'id': 'l3',
      'name': 'Suresh Reddy',
      'phone': '+91 7766554433',
      'category': 'AC Repair',
      'status': 'New',
      'note': 'Highly interested, send link.',
      'lastCalled': 'N/A',
    },
    {
      'id': 'l4',
      'name': 'Gautam Sen',
      'phone': '+91 6655443322',
      'category': 'Electrical Services',
      'status': 'Not Interested',
      'note': 'Already using another aggregator.',
      'lastCalled': '2026-06-15',
    },
  ];

  final List<Map<String, dynamic>> _stuckVendors = [
    {
      'id': 's1',
      'businessName': 'Balaji Electricals',
      'ownerName': 'Venkatesh Prasad',
      'phone': '+91 9443322110',
      'stuckStage': 'Verification Documents',
      'lastActive': '2 hours ago',
      'helperNote': 'Uploaded GST but Aadhaar selfie failed.',
    },
    {
      'id': 's2',
      'businessName': 'Quick Dry Cleaners',
      'ownerName': 'Sonia Gandhi',
      'phone': '+91 8332211009',
      'stuckStage': 'Service Additions',
      'lastActive': '1 day ago',
      'helperNote': 'Stuck selecting subcategory pricing list.',
    },
    {
      'id': 's3',
      'businessName': 'Home-care Solutions',
      'ownerName': 'Amit Shah',
      'phone': '+91 7221100998',
      'stuckStage': 'OTP Verification',
      'lastActive': '3 days ago',
      'helperNote': 'Entered wrong number twice during signup.',
    },
  ];

  final List<String> _categoriesList = [
    'Home Cleaning',
    'Plumbing',
    'AC & Appliance Repair',
    'Electrical Services',
    'Salon & Beauty',
    'Painting',
  ];

  int _totalReferralPoints = 0;
  int _weeklyOnboardings = 0;
  int _monthlyOnboardings = 0;
  double _estimatedReferralPayout = 0.0;
  double _monthlyPayoutBonus = 0.0;
  double _withdrawableBalance = 0.0;
  double _totalWithdrawn = 0.0;

  List<TelecallerOnboardedVendorModel> _onboardedVendors = [];
  bool _isLoadingVendors = true;
  DateTime? _startDate;
  DateTime? _endDate;
  int _vendorsTotal = 0;
  int _skip = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
    _fetchOnboardedVendors();
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _vendorPhoneController.dispose();
    _invitePhoneController.dispose();
    _companyLeadsSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardStats() async {
    try {
      final employeeApiService = di.sl<EmployeeApiService>();
      final stats = await employeeApiService.telecallerDashboardStats();
      if (mounted) {
        setState(() {
          _weeklyOnboardings = stats.weeklyOnboardings;
          _monthlyOnboardings = stats.monthlyConversions;
          _totalReferralPoints = stats.referralPoints;
          _estimatedReferralPayout = stats.estimatedReferralPayout;
          _monthlyPayoutBonus = stats.monthlyPayoutBonus;
          _withdrawableBalance = stats.withdrawableBalance;
          _totalWithdrawn = stats.totalWithdrawn;
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch stats: $e");
    }
  }

  bool _isCompanyLeadSource(String? source) {
    final s = source?.toLowerCase() ?? '';
    return s == 'company' ||
        s == 'company_website' ||
        s == 'company_mobile' ||
        s.isEmpty;
  }

  Future<void> _fetchOnboardedVendors({
    bool loadMore = false,
    String? leadSource,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final pageLimit = limit ?? _limit;
    if (!loadMore) {
      setState(() {
        _skip = 0;
        _isLoadingVendors = true;
        _onboardedVendors.clear();
      });
    }

    try {
      final employeeApiService = di.sl<EmployeeApiService>();
      final effectiveStart = startDate ?? _startDate;
      final effectiveEnd = endDate ?? _endDate;
      final dateStartStr = effectiveStart != null
          ? effectiveStart.toIso8601String().split('T')[0]
          : null;
      final dateEndStr = effectiveEnd != null
          ? effectiveEnd.toIso8601String().split('T')[0]
          : null;

      final response = await employeeApiService.telecallerDashboardOnboarded(
        startDate: dateStartStr,
        endDate: dateEndStr,
        skip: _skip,
        limit: pageLimit,
        leadSource: leadSource,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _onboardedVendors.addAll(response.vendors);
          } else {
            _onboardedVendors = response.vendors;
          }
          _vendorsTotal = response.total;
          _isLoadingVendors = false;
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch vendors: $e");
      if (mounted) {
        setState(() {
          _isLoadingVendors = false;
        });
      }
    }
  }

  Future<void> _showWithdrawalHistoryDialog() async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    List<dynamic> history = [];
    try {
      final apiService = di.sl<EmployeeApiService>();
      history = await apiService.getMyWithdrawals();
      if (mounted) {
        Navigator.pop(context); // Dismiss loader
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load history: $e')),
        );
        return;
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Withdrawal History',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: const Color(0xFF16315D)),
          ),
          content: history.isEmpty
              ? SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'No withdrawal requests found.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.grey.shade600),
                    ),
                  ),
                )
              : SizedBox(
                  width: 450,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, idx) {
                      final req = history[idx];
                      final isPending = req['status'] == 'pending';
                      final dateStr =
                          req['created_at'].toString().split('T')[0];

                      return ListTile(
                        title: Text(
                          '₹${req['amount']}',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Requested on: $dateStr',
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              isPending
                                  ? 'initiated amount will be credited in 30 min - 24hrs'
                                  : 'Sent',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isPending
                                    ? Colors.amber.shade800
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleWithdrawalTap() async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final employeeApiService = di.sl<EmployeeApiService>();
      final profile = await employeeApiService.getEmployeeProfile();

      if (mounted) {
        Navigator.pop(context); // Dismiss loader
      }

      final hasBankDetails = profile.bankName != null &&
          profile.bankName!.trim().isNotEmpty &&
          profile.bankAccountNumber != null &&
          profile.bankAccountNumber!.trim().isNotEmpty &&
          profile.bankIfscCode != null &&
          profile.bankIfscCode!.trim().isNotEmpty;

      if (!hasBankDetails) {
        _showBankDetailsDialog(profile);
      } else {
        _showWithdrawalConfirmationDialog(profile);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile details: $e')),
        );
      }
    }
  }

  void _showBankDetailsDialog(EmployeeProfileModel profile) {
    final holderController = TextEditingController(
        text: (profile.bankAccountName ?? '').isNotEmpty
            ? profile.bankAccountName
            : "${profile.firstName} ${profile.lastName}".trim());
    final bankController = TextEditingController(text: profile.bankName);
    final accountController =
        TextEditingController(text: profile.bankAccountNumber);
    final ifscController = TextEditingController(text: profile.bankIfscCode);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add Bank Details',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: const Color(0xFF16315D)),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please add your bank account details where you want to receive the incentives/commissions.',
                    style: GoogleFonts.outfit(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: holderController,
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF16315D), fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Account Holder Name',
                      labelStyle: GoogleFonts.outfit(
                          color: Colors.grey.shade600, fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF16315D), width: 1.5)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5)),
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bankController,
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF16315D), fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Bank Name',
                      labelStyle: GoogleFonts.outfit(
                          color: Colors.grey.shade600, fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF16315D), width: 1.5)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5)),
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: accountController,
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF16315D), fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      labelStyle: GoogleFonts.outfit(
                          color: Colors.grey.shade600, fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF16315D), width: 1.5)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5)),
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ifscController,
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF16315D), fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'IFSC Code',
                      labelStyle: GoogleFonts.outfit(
                          color: Colors.grey.shade600, fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF16315D), width: 1.5)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5)),
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context); // Close form dialog

                  // Show loader
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final updatedProfile = EmployeeProfileModel(
                      id: profile.id,
                      firstName: profile.firstName,
                      lastName: profile.lastName,
                      email: profile.email,
                      phoneNumber: profile.phoneNumber,
                      role: profile.role,
                      status: profile.status,
                      referralPoints: profile.referralPoints,
                      bankAccountName: holderController.text.trim(),
                      bankName: bankController.text.trim(),
                      bankAccountNumber: accountController.text.trim(),
                      bankIfscCode: ifscController.text.trim(),
                    );

                    final apiService = di.sl<EmployeeApiService>();
                    final savedProfile =
                        await apiService.updateEmployeeProfile(updatedProfile);

                    if (mounted) {
                      Navigator.pop(context); // Dismiss loader
                      _showWithdrawalConfirmationDialog(savedProfile);
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context); // Dismiss loader
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to save bank details: $e')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16315D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save & Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showWithdrawalConfirmationDialog(EmployeeProfileModel profile) {
    final amountController =
        TextEditingController(text: _withdrawableBalance.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Request Withdrawal',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: const Color(0xFF16315D)),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance: ₹${_withdrawableBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFFD4A33A)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF16315D), fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Withdrawal Amount (₹)',
                      labelStyle: GoogleFonts.outfit(
                          color: Colors.grey.shade600, fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF16315D), width: 1.5)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.5)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      final amt = double.tryParse(val);
                      if (amt == null || amt <= 0) return 'Invalid amount';
                      if (amt > _withdrawableBalance)
                        return 'Insufficient balance';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Bank Details Snapshot:',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: const Color(0xFF16315D)),
                  ),
                  const SizedBox(height: 6),
                  Text('Holder: ${profile.bankAccountName}',
                      style: GoogleFonts.outfit(fontSize: 12)),
                  Text('Bank: ${profile.bankName}',
                      style: GoogleFonts.outfit(fontSize: 12)),
                  Text('Acc No: ${profile.bankAccountNumber}',
                      style: GoogleFonts.outfit(fontSize: 12)),
                  Text('IFSC: ${profile.bankIfscCode}',
                      style: GoogleFonts.outfit(fontSize: 12)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showWithdrawalHistoryDialog();
              },
              child: const Text('History'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final amt = double.parse(amountController.text.trim());
                  Navigator.pop(context); // Close confirm dialog

                  // Show loader
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final apiService = di.sl<EmployeeApiService>();
                    await apiService.requestWithdrawal(amt);

                    if (mounted) {
                      Navigator.pop(context); // Dismiss loader
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'initiated amount will be credited in 30 min - 24hrs')),
                      );
                      // Reload stats
                      _fetchDashboardStats();
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context); // Dismiss loader
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Withdrawal request failed: $e')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Request'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    // Legacy method - redirected to custom range
    await _selectCustomDateRange();
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0C3D98),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
              secondary: Color(0xFF0C3D98),
            ),
            dialogBackgroundColor: const Color(0xFF0F172A),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 550),
              child: child,
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchOnboardedVendors();
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFFD1FAE5);
      case 'slots done':
        return const Color(0xFFDBEAFE);
      case 'services added':
        return const Color(0xFFFEF3C7);
      case 'business registration':
        return const Color(0xFFF3E8FF);
      case 'registration':
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF065F46);
      case 'slots done':
        return const Color(0xFF1E40AF);
      case 'services added':
        return const Color(0xFF92400E);
      case 'business registration':
        return const Color(0xFF6B21A8);
      case 'registration':
      default:
        return const Color(0xFF475569);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
      );
    }
  }

  Future<void> _approveVendor(TelecallerOnboardedVendorModel vendor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Approve Vendor',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Approve ${vendor.businessName.isEmpty ? vendor.firstName : vendor.businessName} and set status to Active?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final api = di.sl<EmployeeApiService>();
      await api.approveVendor(vendor.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendor approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      final isWebsite = _activeMenuIndex == 2;
      await _fetchOnboardedVendors(
        leadSource: isWebsite ? 'company_website' : 'company_mobile',
        startDate: _companyLeadsStartDate,
        endDate: _companyLeadsEndDate,
        limit: 50,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Approve failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectVendor(TelecallerOnboardedVendorModel vendor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject Vendor',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to reject ${vendor.businessName.isEmpty ? vendor.firstName : vendor.businessName}?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final api = di.sl<EmployeeApiService>();
      await api.rejectVendor(vendor.id);
      if (!mounted) return;
      setState(() {
        _onboardedVendors.removeWhere((v) => v.id == vendor.id);
        if (_vendorsTotal > 0) _vendorsTotal--;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendor rejected successfully'),
          backgroundColor: Colors.red,
        ),
      );
      final isWebsite = _activeMenuIndex == 2;
      await _fetchOnboardedVendors(
        leadSource: isWebsite ? 'company_website' : 'company_mobile',
        startDate: _companyLeadsStartDate,
        endDate: _companyLeadsEndDate,
        limit: 50,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reject failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendWhatsAppInvite(
      String phoneNumber, String vendorName) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final employeeApiService = di.sl<EmployeeApiService>();
      final result =
          await employeeApiService.sendWhatsAppInvite(phoneNumber, vendorName);

      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Dismiss loading
      }

      if (result['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp invitation sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(result['error'] ?? 'Failed to send WhatsApp message');
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Dismiss loading
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send WhatsApp invite: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _addQuickOnboardingLead() {
    final name = _vendorNameController.text.trim();
    final phone = _vendorPhoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _leads.insert(0, {
        'id': 'l_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'phone': phone,
        'category': _selectedCategory,
        'status': 'New',
        'note': 'Added from Quick Onboarding panel.',
        'lastCalled': 'N/A',
      });
      _totalReferralPoints += 10; // 10 points for adding lead
    });

    _vendorNameController.clear();
    _vendorPhoneController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Color(0xFF10B981), size: 30),
            const SizedBox(width: 10),
            Text('Lead Registered!',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0C3D98))),
          ],
        ),
        content: Text(
          'Vendor "$name" has been successfully added to your Lead Pipeline.\nWould you like to send them the Invite Link now?',
          style: GoogleFonts.outfit(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C3D98),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _sendWhatsAppInvite(phone, name);
            },
            child: Text('WhatsApp Link',
                style: GoogleFonts.outfit(color: Colors.white)),
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

    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminBloc>(
          create: (_) => di.sl<AdminBloc>(),
        ),
        BlocProvider<EmployeeProfileBloc>(
          create: (_) =>
              di.sl<EmployeeProfileBloc>()..add(LoadEmployeeProfile()),
        ),
      ],
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Bar
                      BlocBuilder<AdminBloc, AdminState>(
                        builder: (context, state) {
                          return _buildTopBar(context, isDark, token);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Content Layout
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Sidebar
                            if (MediaQuery.of(context).size.width > 800) ...[
                              _buildSidebar(context, isDark),
                              const SizedBox(width: 24),
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
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.white.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(28),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: BlocConsumer<AdminBloc, AdminState>(
                                      listener: (context, state) {
                                        if (state.successMessage != null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text(state.successMessage!),
                                                backgroundColor: Colors.green),
                                          );
                                        }
                                        if (state.error != null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(state.error!),
                                                backgroundColor: Colors.red),
                                          );
                                        }
                                      },
                                      builder: (context, state) {
                                        return _buildActiveTabContent(
                                            context, isDark);
                                      },
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
                  if (index == 0) {
                    _fetchOnboardedVendors();
                  } else if (index == 2) {
                    _fetchOnboardedVendors(
                      leadSource: 'company_website',
                      startDate: _companyLeadsStartDate,
                      endDate: _companyLeadsEndDate,
                      limit: 50,
                    );
                  } else if (index == 3) {
                    _fetchOnboardedVendors(
                      leadSource: 'company_mobile',
                      startDate: _companyLeadsStartDate,
                      endDate: _companyLeadsEndDate,
                      limit: 50,
                    );
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined), label: 'Stats'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.add_link_outlined), label: 'Invite'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.language_outlined), label: 'Website'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.phone_android_outlined),
                      label: 'Application'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings_outlined), label: 'Settings'),
                ],
              )
            : null,
      ),
    );
  }

  // ==========================================
  // TOP BAR WIDGET
  // ==========================================
  Widget _buildTopBar(BuildContext context, bool isDark, String token) {
    return BlocBuilder<EmployeeProfileBloc, EmployeeProfileState>(
      builder: (context, profileState) {
        String displayName = 'AM5 ROYAL';
        String initials = 'TC';
        EmployeeProfileModel? currentProfile;

        if (profileState is EmployeeProfileLoaded) {
          currentProfile = profileState.profile;
          displayName =
              '${currentProfile.firstName} ${currentProfile.lastName}'.trim();
          if (displayName.isEmpty) displayName = 'AM5 ROYAL';

          if (currentProfile.firstName.isNotEmpty) {
            initials = currentProfile.firstName[0].toUpperCase();
            if (currentProfile.lastName.isNotEmpty) {
              initials += currentProfile.lastName[0].toUpperCase();
            }
          }
        } else if (profileState is EmployeeProfileUpdateSuccess) {
          currentProfile = profileState.profile;
          displayName =
              '${currentProfile.firstName} ${currentProfile.lastName}'.trim();
          if (displayName.isEmpty) displayName = 'AM5 ROYAL';

          if (currentProfile.firstName.isNotEmpty) {
            initials = currentProfile.firstName[0].toUpperCase();
            if (currentProfile.lastName.isNotEmpty) {
              initials += currentProfile.lastName[0].toUpperCase();
            }
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.3),
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
                    height: 38,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.star,
                        color: Color(0xFFD4A33A),
                        size: 30),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: const Color(0xFFD4A33A),
                        ),
                      ),
                      Text(
                        'Verification Dashboard',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
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
                  ElevatedButton.icon(
                    onPressed: () => context.push('/telecaller/vendor-onboard'),
                    icon: const Icon(Icons.person_add_alt_1,
                        color: Colors.white, size: 16),
                    label: Text(
                      'Add New Vendor',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3D98),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User avatar indicator
                  InkWell(
                    onTap: () {
                      if (currentProfile != null) {
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<EmployeeProfileBloc>(),
                            child: EditProfileDialog(profile: currentProfile!),
                          ),
                        );
                      } else {
                        if (profileState is EmployeeProfileError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to load profile: ${profileState.message}. Retrying...'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          context
                              .read<EmployeeProfileBloc>()
                              .add(LoadEmployeeProfile());
                        } else if (profileState is EmployeeProfileLoading) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Profile is loading, please wait...'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile not loaded. Retrying...'),
                            ),
                          );
                          context
                              .read<EmployeeProfileBloc>()
                              .add(LoadEmployeeProfile());
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : const Color(0xFFE0F1FF),
                      child: Text(initials,
                          style: const TextStyle(
                              color: Color(0xFF0C3D98),
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        color: _isHoveredLogout
                            ? Colors.redAccent
                            : (isDark ? Colors.white70 : Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // SIDEBAR WIDGET (DESKTOP)
  // ==========================================
  Widget _buildSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSidebarButton(
              0, Icons.dashboard_outlined, 'Performance Dashboard', isDark),
          const SizedBox(height: 12),
          _buildSidebarButton(
              1, Icons.add_link_outlined, 'WhatsApp & SMS', isDark),
          const SizedBox(height: 12),
          _buildSidebarButton(
              2, Icons.language_outlined, 'Company Website Leads', isDark),
          const SizedBox(height: 12),
          _buildSidebarButton(3, Icons.phone_android_outlined,
              'Company Application Leads', isDark),
          const SizedBox(height: 12),
          _buildSidebarButton(4, Icons.settings_outlined, 'Settings', isDark),
          const Spacer(),
          // Static Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF111B2F), const Color(0xFF1E293B)]
                    : [const Color(0xFFF0F7FF), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF0C3D98).withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.help_outline,
                    color: Color(0xFF2E8BF0), size: 20),
                const SizedBox(height: 8),
                Text(
                  'Stitch Standard',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: const Color(0xFF16315D)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add leads directly while on the phone with potential vendors to lock in referral point claims.',
                  style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: const Color(0xFF6C84A5),
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarButton(
      int index, IconData icon, String title, bool isDark) {
    final isSelected = _activeMenuIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeMenuIndex = index;
        });
        if (index == 0) {
          _fetchOnboardedVendors();
        } else if (index == 2) {
          _fetchOnboardedVendors(
            leadSource: 'company_website',
            startDate: _companyLeadsStartDate,
            endDate: _companyLeadsEndDate,
            limit: 50,
          );
        } else if (index == 3) {
          _fetchOnboardedVendors(
            leadSource: 'company_mobile',
            startDate: _companyLeadsStartDate,
            endDate: _companyLeadsEndDate,
            limit: 50,
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0C3D98) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0C3D98).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : const Color(0xFF6C84A5)),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : const Color(0xFF16315D)),
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
        return _buildPerformanceOverviewTab(context, isDark);
      case 1:
        return _buildQuickInviteTab(context, isDark);
      case 2:
        return _buildCompanyLeadsTab(context, isDark, isWebsite: true);
      case 3:
        return _buildCompanyLeadsTab(context, isDark, isWebsite: false);
      case 4:
        return _buildSettingsTab(context, isDark);
      default:
        return _buildPerformanceOverviewTab(context, isDark);
    }
  }

  Widget _buildSettingsTab(BuildContext context, bool isDark) {
    return BlocBuilder<EmployeeProfileBloc, EmployeeProfileState>(
      builder: (context, profileState) {
        EmployeeProfileModel? profile;
        if (profileState is EmployeeProfileLoaded) {
          profile = profileState.profile;
        } else if (profileState is EmployeeProfileUpdateSuccess) {
          profile = profileState.profile;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Settings',
              style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0D3B66)),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your telecaller profile and account settings.',
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : const Color(0xFF6C84A5)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFD8E6F5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile != null
                        ? '${profile.firstName} ${profile.lastName}'.trim()
                        : 'Profile',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF16315D)),
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: 8),
                    Text(profile.email,
                        style: GoogleFonts.outfit(
                            fontSize: 13, color: Colors.grey[600])),
                    Text(profile.phoneNumber,
                        style: GoogleFonts.outfit(
                            fontSize: 13, color: Colors.grey[600])),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (profile != null) {
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<EmployeeProfileBloc>(),
                            child: EditProfileDialog(profile: profile!),
                          ),
                        );
                      } else {
                        context
                            .read<EmployeeProfileBloc>()
                            .add(LoadEmployeeProfile());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Loading profile, please try again...')),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.white, size: 16),
                    label: Text('Edit Profile',
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3D98),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 1: PERFORMANCE OVERVIEW
  // ==========================================
  Widget _buildPerformanceOverviewTab(BuildContext context, bool isDark) {
    final performanceVendors = _onboardedVendors
        .where((v) => !_isCompanyLeadSource(v.leadSource))
        .toList();

    final mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Metrics Row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Weekly Onboarding',
                '$_weeklyOnboardings',
                '',
                Icons.trending_up,
                isDark,
                const Color(0xFF0C3D98),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Monthly Conversions',
                '$_monthlyOnboardings',
                'Payout bonus: +₹${_monthlyPayoutBonus.toStringAsFixed(0)}',
                Icons.verified_user,
                isDark,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: _handleWithdrawalTap,
                borderRadius: BorderRadius.circular(20),
                child: _buildMetricCard(
                  'Incentives/Commission',
                  '₹${_estimatedReferralPayout.toStringAsFixed(0)}',
                  'Withdrawable: ₹${_withdrawableBalance.toStringAsFixed(0)} (Tap to Withdraw)',
                  Icons.payments_outlined,
                  isDark,
                  const Color(0xFFD4A33A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Onboarded Vendors List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Onboarded Vendors Details',
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF16315D)),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                final now = DateTime.now();
                if (value == 'today') {
                  setState(() {
                    _startDate = DateTime(now.year, now.month, now.day);
                    _endDate = now;
                  });
                  _fetchOnboardedVendors();
                } else if (value == 'week') {
                  setState(() {
                    _startDate = now.subtract(Duration(days: now.weekday - 1));
                    _endDate = now;
                  });
                  _fetchOnboardedVendors();
                } else if (value == 'month') {
                  setState(() {
                    _startDate = DateTime(now.year, now.month, 1);
                    _endDate = now;
                  });
                  _fetchOnboardedVendors();
                } else if (value == '30days') {
                  setState(() {
                    _startDate = now.subtract(const Duration(days: 30));
                    _endDate = now;
                  });
                  _fetchOnboardedVendors();
                } else if (value == 'all') {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                  _fetchOnboardedVendors();
                } else if (value == 'custom') {
                  await _selectCustomDateRange();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'all', child: Text('All Time')),
                const PopupMenuItem(value: 'today', child: Text('Today')),
                const PopupMenuItem(value: 'week', child: Text('This Week')),
                const PopupMenuItem(value: 'month', child: Text('This Month')),
                const PopupMenuItem(
                    value: '30days', child: Text('Last 30 Days')),
                const PopupMenuItem(
                    value: 'custom', child: Text('Custom Range...')),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFD8E6F5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range,
                        size: 14,
                        color: isDark ? Colors.white70 : Colors.black87),
                    const SizedBox(width: 8),
                    Text(
                      _startDate != null && _endDate != null
                          ? '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}'
                          : 'Filter by Date',
                      style: GoogleFonts.outfit(
                          fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.5)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFD8E6F5)),
          ),
          child: _isLoadingVendors
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              : performanceVendors.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No vendors onboarded yet.',
                          style: GoogleFonts.outfit(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: performanceVendors.length,
                          separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : const Color(0xFFD8E6F5)),
                          itemBuilder: (context, index) {
                            final vendor = performanceVendors[index];
                            final dateStr = vendor.createdAt.split('T')[0];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F1FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.storefront,
                                        color: Color(0xFF0C3D98), size: 18),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(vendor.businessName,
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text(
                                            '${vendor.mobileNumber} • $dateStr',
                                            style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusBgColor(vendor.status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      vendor.status.toUpperCase(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _getStatusTextColor(vendor.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (_onboardedVendors.length < _vendorsTotal)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _skip += _limit;
                                });
                                _fetchOnboardedVendors(loadMore: true);
                              },
                              child: Text(
                                  'Load More (${_vendorsTotal - _onboardedVendors.length} left)',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'My Performance Overview',
          style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D3B66)),
        ),
        const SizedBox(height: 4),
        Text(
          'Real-time stats tracking your successful referral conversions, calls, and point history.',
          style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF6C84A5)),
        ),
        const SizedBox(height: 24),
        mainContent,
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subText,
      IconData icon, bool isDark, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFD8E6F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6C84A5)),
              ),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF16315D)),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: GoogleFonts.outfit(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: LEAD PIPELINE
  // ==========================================
  Widget _buildLeadPipelineTab(BuildContext context, bool isDark) {
    // Filter leads
    final filteredLeads = _leads
        .where((l) =>
            l['status'].toLowerCase() == _selectedPipelineTab.toLowerCase())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lead Pipeline & Calls',
                    style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0D3B66)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a filter below to manage lists, check notes, and call target vendors.',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFF6C84A5)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Floating count indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0C3D98).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Total Leads: ${_leads.length}',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: const Color(0xFF0C3D98)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tabs Selector Row
        Row(
          children: [
            _buildPipelineFilterTab('New', isDark),
            const SizedBox(width: 8),
            _buildPipelineFilterTab('Follow-up', isDark),
            const SizedBox(width: 8),
            _buildPipelineFilterTab('Not Interested', isDark),
          ],
        ),
        const SizedBox(height: 16),

        // Pipeline List
        if (filteredLeads.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 60),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.contact_phone_outlined,
                    size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'No leads in "$_selectedPipelineTab" list',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add a new lead in the "Invite Tool" tab or adjust filters.',
                  style:
                      GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredLeads.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lead = filteredLeads[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFD8E6F5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left avatar with letter
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFE0F1FF),
                      child: Text(lead['name'][0],
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF0C3D98),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    const SizedBox(width: 16),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(lead['name'],
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: const Color(0xFF16315D))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF5FC),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(lead['category'],
                                    style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        color: const Color(0xFF0C3D98),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(lead['phone'],
                              style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          // Note Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurfaceVariant
                                  : const Color(0xFFF7FBFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isDark
                                      ? Colors.transparent
                                      : const Color(0xFFE8F1FC)),
                            ),
                            child: Text(
                              lead['note'] ?? 'No feedback recorded yet.',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: const Color(0xFF6C84A5)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last call attempt: ${lead['lastCalled']}',
                            style: GoogleFonts.outfit(
                                fontSize: 10, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Actions
                    Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  lead['lastCalled'] =
                                      '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
                                });
                                _makePhoneCall(lead['phone']);
                              },
                              icon: const Icon(Icons.call,
                                  color: Color(0xFF10B981)),
                              tooltip: 'Call Phone',
                            ),
                            IconButton(
                              onPressed: () {
                                _sendWhatsAppInvite(
                                    lead['phone'], lead['name']);
                              },
                              icon: const Icon(Icons.chat_bubble_outline,
                                  color: Color(0xFF2E8BF0)),
                              tooltip: 'Send WhatsApp Invite',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Dropdown to update status
                        PopupMenuButton<String>(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C3D98),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Action',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onSelected: (newStatus) {
                            setState(() {
                              lead['status'] = newStatus;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Moved ${lead['name']} to $newStatus list.')),
                            );
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'New', child: Text('Mark as New Lead')),
                            const PopupMenuItem(
                                value: 'Follow-up',
                                child: Text('Mark as Follow-up')),
                            const PopupMenuItem(
                                value: 'Not Interested',
                                child: Text('Mark as Not Interested')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPipelineFilterTab(String tabName, bool isDark) {
    final isSelected = _selectedPipelineTab == tabName;
    final count = _leads
        .where((l) => l['status'].toLowerCase() == tabName.toLowerCase())
        .length;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPipelineTab = tabName;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0C3D98)
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0C3D98)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFD8E6F5)),
          ),
        ),
        child: Row(
          children: [
            Text(
              tabName,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF16315D)),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFEEF5FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF0C3D98),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: QUICK INVITE TOOL
  // ==========================================
  Widget _buildQuickInviteTab(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Vendor Onboarding & Invitation',
          style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D3B66)),
        ),
        const SizedBox(height: 4),
        Text(
          'Fill in details of the service provider you are talking to, save them as a lead, and dispatch onboarding links directly.',
          style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF6C84A5)),
        ),
        const SizedBox(height: 24),

        // Card Container
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFD8E6F5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Vendor Phone Details',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF16315D)),
              ),
              const SizedBox(height: 20),

              // Vendor Name
              _buildInputLabel('Owner/Vendor Full Name', isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _vendorNameController,
                style: GoogleFonts.outfit(fontSize: 14),
                decoration: _buildInputDecoration(
                    'e.g. Ramesh Kumar', Icons.person_outline, isDark),
              ),
              const SizedBox(height: 20),

              // Vendor Phone
              _buildInputLabel('Mobile Phone Number', isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _vendorPhoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.outfit(fontSize: 14),
                decoration: _buildInputDecoration(
                    '+91 98765 43210', Icons.phone_android, isDark),
              ),
              const SizedBox(height: 20),

              // Category dropdown
              _buildInputLabel('Primary Category Area', isDark),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : const Color(0xFFF7FBFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? Colors.transparent
                          : const Color(0xFFD8E6F5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor:
                        isDark ? AppColors.darkSurface : Colors.white,
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: const Color(0xFF16315D),
                        fontWeight: FontWeight.w500),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xFF0C3D98)),
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
              const SizedBox(height: 32),

              // Submit Actions Row
              Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0C3D98).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _addQuickOnboardingLead,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_outlined,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Register Lead & Invite',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF16315D),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      String hint, IconData prefixIcon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(
          color: isDark ? Colors.white30 : const Color(0xFF94A8C5),
          fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF0C3D98), size: 18),
      filled: true,
      fillColor:
          isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF7FBFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: isDark ? Colors.transparent : const Color(0xFFD8E6F5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: isDark ? Colors.transparent : const Color(0xFFD8E6F5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2B7DE1), width: 1.5),
      ),
    );
  }

  // ==========================================
  // TAB 4: VERIFICATION SUPPORT LINE (7-STEP WORKFLOW)
  // ==========================================
  int _getStepIndex(String status) {
    final s = status.toLowerCase().trim();
    switch (s) {
      case 'services':
      case 'services added':
      case 'services_added':
        return 0;
      case 'slots':
      case 'slots done':
      case 'slots_done':
        return 1;
      case 'registration':
        return 2;
      case 'business registration':
      case 'business reg':
      case 'business_registration':
        return 3;
      case 'payment':
      case 'payment completed':
      case 'payment_completed':
      case 'payment done':
        return 4;
      case 'temporary active':
      case 'temporary_active':
      case 'temp active':
      case 'temp_active':
        return 5;
      case 'active':
      case 'activated':
      case 'account activated':
      case 'account_activated':
        return 6;
      default:
        return 0;
    }
  }

  Widget _buildVendorStepperCard(
      TelecallerOnboardedVendorModel vendor, bool isDark) {
    final int currentStep = _getStepIndex(vendor.status);
    final List<String> steps = [
      'Services',
      'Slots',
      'Registration',
      'Business Reg',
      'Payment',
      'Temp Active',
      'Activated'
    ];

    final statusLower = vendor.status.toLowerCase();
    final bool isUnderVerification =
        statusLower == 'temporary active' || statusLower == 'temporary_active';
    // Show Approve/Reject for Temp Active (Website + Application), assigned or not.
    final bool showApproveReject = isUnderVerification;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFD8E6F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.storefront,
                    color: Color(0xFF0C3D98), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.businessName.isEmpty
                          ? 'Unknown Business'
                          : vendor.businessName,
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              isDark ? Colors.white : const Color(0xFF16315D)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vendor.firstName} ${vendor.lastName} • ${vendor.mobileNumber}',
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (vendor.leadSource == 'company' ||
                  vendor.leadSource == 'company_website' ||
                  vendor.leadSource == 'company_mobile')
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    vendor.leadSource == 'company_mobile'
                        ? 'Application Lead'
                        : 'Website Lead',
                    style: GoogleFonts.outfit(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (showApproveReject) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => _rejectVendor(vendor),
                  child: Text('Reject',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => _approveVendor(vendor),
                  child: Text('Approve',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C3D98),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () => _makePhoneCall(vendor.mobileNumber),
                icon: const Icon(Icons.support_agent,
                    color: Colors.white, size: 16),
                label: Text('Assist Now',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stepper
          Row(
            children: List.generate(steps.length, (index) {
              final stepName = steps[index];
              bool isCompleted = false;
              if (stepName == 'Services') {
                isCompleted = vendor.hasServices;
              } else if (stepName == 'Slots') {
                isCompleted = vendor.hasSlots;
              } else if (stepName == 'Registration') {
                isCompleted = vendor.hasRegistration;
              } else if (stepName == 'Business Reg') {
                isCompleted = vendor.hasBusinessReg;
              } else if (stepName == 'Payment') {
                isCompleted = vendor.hasPayment;
              }

              final isActivated = stepName == 'Activated' &&
                  (vendor.isActivated ||
                      statusLower == 'active' ||
                      statusLower == 'activated');
              final isTempActive = stepName == 'Temp Active' &&
                  (vendor.isTempActive || isUnderVerification);
              final isCurrent = index == currentStep;

              Color bgColor =
                  isDark ? Colors.grey.shade900 : const Color(0xFFF3F4F6);
              Color borderColor = isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFE5E7EB);
              Color textColor =
                  isDark ? Colors.grey[400]! : Colors.grey[700]!;

              if (isActivated) {
                bgColor = const Color(0xFF0C3D98);
                borderColor = const Color(0xFF0C3D98);
                textColor = Colors.white;
              } else if (isTempActive) {
                bgColor = Colors.orange;
                borderColor = Colors.orange;
                textColor = Colors.white;
              } else if (isCompleted) {
                bgColor = const Color(0xFF10B981);
                borderColor = const Color(0xFF10B981);
                textColor = Colors.white;
              } else if (isCurrent) {
                bgColor =
                    isDark ? Colors.grey.shade800 : const Color(0xFFE2E8F0);
                borderColor =
                    isDark ? Colors.grey.shade700 : const Color(0xFFCBD5E1);
                textColor =
                    isDark ? Colors.white70 : const Color(0xFF334155);
              }

              return Expanded(
                child: InkWell(
                  onTap: () =>
                      _showStepDetailsModal(context, vendor, stepName, isDark),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                      boxShadow: isActivated
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0C3D98)
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isCompleted ? '✓ $stepName' : stepName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (isUnderVerification) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                '(Under Verification)',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyLeadsTab(BuildContext context, bool isDark,
      {required bool isWebsite}) {
    final filteredVendors = _onboardedVendors.where((v) {
      if (v.status.toLowerCase() == 'rejected') return false;

      final source = v.leadSource?.toLowerCase() ?? '';
      if (isWebsite) {
        if (!(source == 'company' ||
            source == 'company_website' ||
            source.isEmpty)) {
          return false;
        }
      } else {
        if (source != 'company_mobile') return false;
      }

      final query = _companyLeadsSearchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final haystack =
            '${v.businessName} ${v.firstName} ${v.lastName} ${v.mobileNumber}'
                .toLowerCase();
        if (!haystack.contains(query)) return false;
      }

      if (_companyLeadsStatusFilter != 'All') {
        if (v.status.toLowerCase() != _companyLeadsStatusFilter.toLowerCase()) {
          return false;
        }
      }

      if (_companyLeadsStartDate != null || _companyLeadsEndDate != null) {
        DateTime? created;
        try {
          created = DateTime.parse(v.createdAt);
        } catch (_) {
          created = null;
        }
        if (created != null) {
          if (_companyLeadsStartDate != null &&
              created.isBefore(_companyLeadsStartDate!)) {
            return false;
          }
          if (_companyLeadsEndDate != null &&
              created.isAfter(
                  _companyLeadsEndDate!.add(const Duration(days: 1)))) {
            return false;
          }
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        int rank(String status) {
          final s = status.toLowerCase();
          if (s == 'temporary active' || s == 'temporary_active') return 0;
          if (s == 'payment') return 1;
          return 2;
        }

        final byStatus = rank(a.status).compareTo(rank(b.status));
        if (byStatus != 0) return byStatus;
        return b.createdAt.compareTo(a.createdAt);
      });

    final statusOptions = <String>{
      'All',
      ..._onboardedVendors.map((v) => v.status).where((s) => s.isNotEmpty),
    }.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isWebsite ? 'Company Website Leads' : 'Company Application Leads',
          style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D3B66)),
        ),
        const SizedBox(height: 4),
        Text(
          isWebsite
              ? 'This section displays all leads generated from the Company Website.'
              : 'This section displays all leads generated from the Company Application.',
          style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF6C84A5)),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: _companyLeadsSearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search name, business, phone',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                style: GoogleFonts.outfit(fontSize: 13),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD8E6F5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: statusOptions.contains(_companyLeadsStatusFilter)
                      ? _companyLeadsStatusFilter
                      : 'All',
                  items: statusOptions
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s,
                                style: GoogleFonts.outfit(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _companyLeadsStatusFilter = value);
                  },
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2024),
                  lastDate: now,
                  initialDateRange: _companyLeadsStartDate != null &&
                          _companyLeadsEndDate != null
                      ? DateTimeRange(
                          start: _companyLeadsStartDate!,
                          end: _companyLeadsEndDate!)
                      : null,
                );
                if (range != null) {
                  setState(() {
                    _companyLeadsStartDate = range.start;
                    _companyLeadsEndDate = range.end;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD8E6F5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.date_range, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _companyLeadsStartDate != null &&
                              _companyLeadsEndDate != null
                          ? '${_companyLeadsStartDate!.day}/${_companyLeadsStartDate!.month} - ${_companyLeadsEndDate!.day}/${_companyLeadsEndDate!.month}'
                          : 'Date Filter',
                      style: GoogleFonts.outfit(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            if (_companyLeadsStartDate != null ||
                _companyLeadsStatusFilter != 'All' ||
                _companyLeadsSearchController.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _companyLeadsSearchController.clear();
                    _companyLeadsStatusFilter = 'All';
                    _companyLeadsStartDate = null;
                    _companyLeadsEndDate = null;
                  });
                },
                child: Text('Clear Filters',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _isLoadingVendors
            ? const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            : filteredVendors.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No leads found.',
                        style: GoogleFonts.outfit(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredVendors.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final vendor = filteredVendors[index];
                      return _buildVendorStepperCard(vendor, isDark);
                    },
                  ),
        if (_onboardedVendors.length < _vendorsTotal)
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _skip += _limit;
                });
                _fetchOnboardedVendors(
                  loadMore: true,
                  leadSource: isWebsite ? 'company_website' : 'company_mobile',
                );
              },
              child: Text(
                  'Load More (${_vendorsTotal - _onboardedVendors.length} left)',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  // ==========================================
  // STEP DETAILS MODAL POPUP
  // ==========================================
  void _showStepDetailsModal(
    BuildContext context,
    TelecallerOnboardedVendorModel vendor,
    String stepName,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 650),
            padding: const EdgeInsets.all(24),
            child: FutureBuilder<Map<String, dynamic>>(
              future:
                  di.sl<EmployeeApiService>().getVendorStepDetails(vendor.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      CircularProgressIndicator(
                          color: isDark ? AppColors.accent : AppColors.primary),
                      const SizedBox(height: 20),
                      Text('Fetching $stepName details...',
                          style: GoogleFonts.outfit(
                              color: isDark ? Colors.white70 : Colors.black87)),
                      const SizedBox(height: 40),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text('Error loading details',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style:
                              GoogleFonts.outfit(color: Colors.red.shade300)),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close', style: GoogleFonts.outfit()),
                      )
                    ],
                  );
                }

                final data = snapshot.data ?? {};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Modal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F1FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                stepName == 'Services'
                                    ? Icons.design_services
                                    : stepName == 'Slots'
                                        ? Icons.access_time
                                        : stepName == 'Registration'
                                            ? Icons.person
                                            : stepName == 'Business Reg'
                                                ? Icons.badge
                                                : Icons.payment,
                                color: const Color(0xFF0C3D98),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$stepName Details',
                                  style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF16315D)),
                                ),
                                Text(
                                  vendor.businessName.isNotEmpty
                                      ? vendor.businessName
                                      : '${vendor.firstName} ${vendor.lastName}',
                                  style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Content Body based on step
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildModalStepContent(stepName, data, isDark),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C3D98),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalStepContent(
      String stepName, Map<String, dynamic> data, bool isDark) {
    switch (stepName) {
      case 'Services':
        final services = (data['services'] as List?) ?? [];
        if (services.isEmpty) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text('No services added yet.',
                style: GoogleFonts.outfit(color: Colors.grey)),
          ));
        }
        return Column(
          children: services.map((svc) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          svc['title'] ?? 'Service',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (svc['main_category_name'] != null)
                          Text(
                            'Category: ${svc['main_category_name']} → ${svc['sub_category_name'] ?? ''}',
                            style: GoogleFonts.outfit(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        if (svc['description'] != null &&
                            svc['description'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              svc['description'],
                              style: GoogleFonts.outfit(
                                  fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${svc['discounted_price'] ?? svc['price'] ?? '0'}',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green),
                      ),
                      if (svc['price'] != null &&
                          svc['discounted_price'] != null &&
                          svc['price'] != svc['discounted_price'])
                        Text(
                          '₹${svc['price']}',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 'Slots':
        final slots = (data['slots'] as List?) ?? [];
        if (slots.isEmpty) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text('No slots/availability added yet.',
                style: GoogleFonts.outfit(color: Colors.grey)),
          ));
        }
        return Column(
          children: slots.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s['day_name'] ?? 'Day',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 6),
                      Text(
                        '${s['start_time']} – ${s['end_time']}',
                        style: GoogleFonts.outfit(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 'Registration':
        final reg = (data['registration'] as Map<String, dynamic>?) ?? {};
        return Column(
          children: [
            _buildDetailRow(
                'Owner Name',
                '${reg['first_name'] ?? ''} ${reg['last_name'] ?? ''}'.trim(),
                isDark),
            _buildDetailRow('Father Name', reg['father_name'] ?? 'N/A', isDark),
            _buildDetailRow(
                'Mobile Number', reg['mobile_number'] ?? 'N/A', isDark),
            _buildDetailRow('Alternative Contact',
                reg['alternative_contact_number'] ?? 'N/A', isDark),
            _buildDetailRow('Email', reg['email'] ?? 'N/A', isDark),
            _buildDetailRow('City', reg['city'] ?? 'N/A', isDark),
            _buildDetailRow('State', reg['state'] ?? 'N/A', isDark),
            _buildDetailRow('Pincode', reg['pincode'] ?? 'N/A', isDark),
            _buildDetailRow('Full Address', reg['address'] ?? 'N/A', isDark),
            _buildDetailRow(
                'Registration Date', reg['created_at'] ?? 'N/A', isDark),
          ],
        );

      case 'Business Reg':
        final biz = (data['business_reg'] as Map<String, dynamic>?) ?? {};
        final docs = (biz['documents'] as List?) ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                'Business Name', biz['business_name'] ?? 'N/A', isDark),
            _buildDetailRow(
                'Aadhaar Number', biz['aadhaar_number'] ?? 'N/A', isDark),
            _buildDetailRow('PAN Number', biz['pan_number'] ?? 'N/A', isDark),
            _buildDetailRow('GST Number', biz['gst_number'] ?? 'N/A', isDark),
            _buildDetailRow('Service Radius',
                '${biz['service_radius_km'] ?? 10} km', isDark),
            const SizedBox(height: 12),
            Text('Uploaded Documents',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            docs.isEmpty
                ? Text('No documents uploaded.',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13))
                : Column(
                    children: docs.map((d) {
                      final docType =
                          (d['document_type'] ?? 'Document').toString();
                      final docUrl = (d['document_url'] ??
                              d['url'] ??
                              d['file_path'] ??
                              '')
                          .toString();
                      final status =
                          (d['verification_status'] ?? 'pending').toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isDark ? Colors.white10 : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  docType,
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: status == 'verified'
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        color: status == 'verified'
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                            if (docUrl.isNotEmpty &&
                                docUrl.startsWith('http')) ...[
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => _showImagePreviewDialog(
                                    context, docUrl, docType),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 160,
                                    width: double.infinity,
                                    color: isDark
                                        ? Colors.black26
                                        : Colors.grey.shade200,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AppNetworkImage(
                                          imageUrl: docUrl,
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                    Icons.broken_image_outlined,
                                                    size: 32,
                                                    color: Colors.grey),
                                                const SizedBox(height: 4),
                                                Text(
                                                    'Failed to load document image',
                                                    style: GoogleFonts.outfit(
                                                        color: Colors.grey,
                                                        fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 8,
                                          bottom: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.fullscreen,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Tap to enlarge',
                                                  style: GoogleFonts.outfit(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (docUrl.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                docUrl,
                                style: GoogleFonts.outfit(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        );

      case 'Payment':
      default:
        final pay = (data['payment'] as Map<String, dynamic>?) ?? {};
        final subs = (pay['subscriptions'] as List?) ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                'Payment Info', pay['payment_info'] ?? 'N/A', isDark),
            const SizedBox(height: 12),
            Text('Subscription Records',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            subs.isEmpty
                ? Text('No subscriptions/payments found.',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13))
                : Column(
                    children: subs.map((s) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              isDark ? Colors.white10 : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['plan_name'] ?? 'Plan',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                Text(
                                  'Payment ID: ${s['payment_id'] ?? 'N/A'}',
                                  style: GoogleFonts.outfit(
                                      fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${s['amount'] ?? 0}',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green),
                                ),
                                Text(
                                  s['status'] ?? 'pending',
                                  style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: s['status'] == 'active'
                                          ? Colors.green
                                          : Colors.orange),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        );
    }
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreviewDialog(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 600, maxWidth: 600),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: InteractiveViewer(
                      clipBehavior: Clip.hardEdge,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 400,
                          placeholder: SizedBox(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image_outlined,
                                      size: 48, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text('Failed to load full image',
                                      style: GoogleFonts.outfit(
                                          color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddVendorDialog extends StatefulWidget {
  final bool isDark;
  final String? prefilledName;
  final String? prefilledPhone;

  const AddVendorDialog({
    super.key,
    required this.isDark,
    this.prefilledName,
    this.prefilledPhone,
  });

  @override
  State<AddVendorDialog> createState() => _AddVendorDialogState();
}

class _AddVendorDialogState extends State<AddVendorDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _aadhaarController;
  late final TextEditingController _panController;
  late final TextEditingController _gstController;
  late final TextEditingController _fssaiController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _radiusController;

  @override
  void initState() {
    super.initState();
    String first = '';
    String last = '';
    String business = '';
    if (widget.prefilledName != null && widget.prefilledName!.isNotEmpty) {
      final parts = widget.prefilledName!.trim().split(' ');
      first = parts.first;
      if (parts.length > 1) {
        last = parts.sublist(1).join(' ');
      }
      business = '${widget.prefilledName} Services';
    }

    _firstNameController = TextEditingController(text: first);
    _lastNameController = TextEditingController(text: last);
    _businessNameController = TextEditingController(text: business);
    _emailController = TextEditingController();
    _phoneController = TextEditingController(text: widget.prefilledPhone);
    _aadhaarController = TextEditingController();
    _panController = TextEditingController();
    _gstController = TextEditingController();
    _fssaiController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _pincodeController = TextEditingController();
    _radiusController = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _gstController.dispose();
    _fssaiController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  InputDecoration buildDialogFieldDecoration({
    required String label,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(
        fontSize: 13,
        color: widget.isDark
            ? AppColors.darkTextSecondary
            : const Color(0xFF6C84A5),
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: widget.isDark
            ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
            : const Color(0xFF6C84A5),
        size: 18,
      ),
      filled: true,
      fillColor: widget.isDark
          ? Colors.white.withValues(alpha: 0.03)
          : const Color(0xFFF3F7FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: widget.isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF0C3D98),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0C3D98).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Color(0xFF0C3D98),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Register New Vendor',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        widget.isDark ? Colors.white : const Color(0xFF0D3B66),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enter partner profile details, location, and KYC info',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : const Color(0xFF6C84A5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 480),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: buildDialogFieldDecoration(
                        label: 'First Name *',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: buildDialogFieldDecoration(
                        label: 'Last Name',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _businessNameController,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: buildDialogFieldDecoration(
                        label: 'Business Name *',
                        prefixIcon: Icons.storefront_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: buildDialogFieldDecoration(
                        label: 'Phone Number *',
                        prefixIcon: Icons.phone_android_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.outfit(fontSize: 14),
                decoration: buildDialogFieldDecoration(
                  label: 'Email Address *',
                  prefixIcon: Icons.mail_outline_rounded,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _aadhaarController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.outfit(fontSize: 14),
                decoration: buildDialogFieldDecoration(
                  label: 'Aadhaar Number (12 digits) *',
                  prefixIcon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _panController,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: buildDialogFieldDecoration(
                        label: 'PAN Card (Optional)',
                        prefixIcon: Icons.credit_card_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _gstController,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: buildDialogFieldDecoration(
                        label: 'GST Number (Optional)',
                        prefixIcon: Icons.business_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fssaiController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: buildDialogFieldDecoration(
                        label: 'FSSAI License (Optional)',
                        prefixIcon: Icons.description_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _radiusController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: buildDialogFieldDecoration(
                        label: 'Radius (KM) *',
                        prefixIcon: Icons.explore_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                style: GoogleFonts.outfit(fontSize: 14),
                maxLines: 2,
                decoration: buildDialogFieldDecoration(
                  label: 'Address *',
                  prefixIcon: Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: buildDialogFieldDecoration(
                        label: 'City *',
                        prefixIcon: Icons.location_city_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _stateController,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: buildDialogFieldDecoration(
                        label: 'State *',
                        prefixIcon: Icons.map_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.outfit(fontSize: 14),
                decoration: buildDialogFieldDecoration(
                  label: 'Pincode (6 digits) *',
                  prefixIcon: Icons.pin_drop_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                widget.isDark ? Colors.white70 : const Color(0xFF4A5568),
            side: BorderSide(
              color: widget.isDark ? Colors.white24 : const Color(0xFFCBD5E0),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          ),
          child: Text('Cancel',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: () {
            final firstName = _firstNameController.text.trim();
            final lastName = _lastNameController.text.trim();
            final businessName = _businessNameController.text.trim();
            final phone = _phoneController.text.trim();
            final email = _emailController.text.trim();
            final aadhaar = _aadhaarController.text.trim();
            final address = _addressController.text.trim();
            final city = _cityController.text.trim();
            final state = _stateController.text.trim();
            final pincode = _pincodeController.text.trim();
            final radius = _radiusController.text.trim();

            if (firstName.isEmpty ||
                businessName.isEmpty ||
                phone.isEmpty ||
                email.isEmpty ||
                aadhaar.isEmpty ||
                address.isEmpty ||
                city.isEmpty ||
                state.isEmpty ||
                pincode.isEmpty ||
                radius.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please fill all required fields (*)'),
                    backgroundColor: Colors.redAccent),
              );
              return;
            }

            if (aadhaar.length != 12 || int.tryParse(aadhaar) == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Aadhaar must be a 12 digit number'),
                    backgroundColor: Colors.redAccent),
              );
              return;
            }

            if (pincode.length != 6 || int.tryParse(pincode) == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Pincode must be a 6 digit number'),
                    backgroundColor: Colors.redAccent),
              );
              return;
            }

            context.read<AdminBloc>().add(
                  CreateVendorSubmitted({
                    'first_name': firstName,
                    'last_name': lastName,
                    'business_name': businessName,
                    'email': email,
                    'phone_number': phone,
                    'aadhaar_number': aadhaar,
                    'pan_card_number': _panController.text.trim(),
                    'gst_number': _gstController.text.trim(),
                    'fssai_license_number': _fssaiController.text.trim(),
                    'address': address,
                    'city': city,
                    'state': state,
                    'pincode': pincode,
                    'service_radius_km': int.tryParse(radius) ?? 10,
                  }),
                );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C3D98),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF0C3D98).withValues(alpha: 0.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
          child: Text('Register',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
