import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/auth_storage_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../../../features/admin/presentation/bloc/admin_event.dart';
import '../../../../features/admin/presentation/bloc/admin_state.dart';
import '../../../../features/admin/domain/entities/admin_employee.dart';
import '../../../../features/admin/domain/entities/admin_vendor.dart';
import '../../../../features/admin/data/datasources/admin_remote_data_source.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../features/supercategory/data/datasources/main_category_api_service.dart';
import '../../../../features/supercategory/data/models/main_category_model.dart';
import '../../../../features/supercategory/data/models/subcategory_model.dart';
import '../../../../features/admin/data/models/company_lead_model.dart';
import 'dart:async';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _activeMenuIndex = 0;
  bool _isHoveredLogout = false;

  // Dialog controllers
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _employeeEmailController =
      TextEditingController();
  final TextEditingController _employeePhoneController =
      TextEditingController();
  final TextEditingController _employeePasswordController =
      TextEditingController();
  String _selectedEmployeeRole = 'verification';

  // Services Management State
  final TextEditingController _serviceNameController = TextEditingController();
  XFile? _selectedServiceImage;
  List<MainCategoryModel> _mainCategories = [];
  List<SubCategoryModel> _subCategories = [];
  MainCategoryModel? _selectedMainCategory;
  SubCategoryModel? _selectedSubCategory;
  bool _isLoadingCategories = true;
  bool _isSavingService = false;
  List<dynamic> _withdrawalRequests = [];
  bool _isLoadingWithdrawals = false;
  List<CompanyLeadModel> _companyLeads = [];
  bool _isLoadingCompanyLeads = false;
  bool _isAssigningLeads = false;
  int _companyLeadsSkip = 0;
  int _companyLeadsLimit = 10;
  int _companyLeadsTotalCount = 0;
  DateTime? _companyLeadsStartDate;
  DateTime? _companyLeadsEndDate;

  // Website Leads state
  List<CompanyLeadModel> _websiteLeads = [];
  bool _isLoadingWebsiteLeads = false;
  int _websiteLeadsSkip = 0;
  final int _websiteLeadsLimit = 20;
  int _websiteLeadsTotalCount = 0;
  DateTime? _websiteLeadsStartDate;
  DateTime? _websiteLeadsEndDate;
  String? _websiteLeadsStatusFilter;
  final TextEditingController _websiteSearchController =
      TextEditingController();
  Timer? _websiteSearchDebounce;

  // Mobile Leads state
  List<CompanyLeadModel> _mobileLeads = [];
  bool _isLoadingMobileLeads = false;
  int _mobileLeadsSkip = 0;
  final int _mobileLeadsLimit = 20;
  int _mobileLeadsTotalCount = 0;
  DateTime? _mobileLeadsStartDate;
  DateTime? _mobileLeadsEndDate;
  String? _mobileLeadsStatusFilter;
  final TextEditingController _mobileSearchController = TextEditingController();
  Timer? _mobileSearchDebounce;

  final TextEditingController _vendorSearchController = TextEditingController();
  Timer? _vendorSearchDebounce;

  @override
  void dispose() {
    _employeeNameController.dispose();
    _employeeEmailController.dispose();
    _employeePhoneController.dispose();
    _employeePasswordController.dispose();
    _serviceNameController.dispose();
    _vendorSearchController.dispose();
    _vendorSearchDebounce?.cancel();
    _websiteSearchController.dispose();
    _websiteSearchDebounce?.cancel();
    _mobileSearchController.dispose();
    _mobileSearchDebounce?.cancel();
    super.dispose();
  }

  void _resetServiceForm() {
    setState(() {
      _serviceNameController.clear();
      _selectedServiceImage = null;
      _isSavingService = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authStorage = di.sl<AuthStorageService>();
    final token = authStorage.getAccessToken() ?? '';

    return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        body: BlocProvider<AdminBloc>(
          create: (_) => di.sl<AdminBloc>()
            ..add(FetchAdminDashboardStats())
            ..add(FetchAdminEmployeesList())
            ..add(FetchAdminVendorsList()),
          child: BlocListener<AuthBloc, AuthState>(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Bar
                        _buildTopBar(context, isDark, token),
                        const SizedBox(height: 24),

                        // Content Layout
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left Menu / Sidebar (visible on screens > 800px)
                              if (MediaQuery.of(context).size.width > 800) ...[
                                _buildSidebar(context, isDark),
                                const SizedBox(width: 24),
                              ],

                              // Main Dashboard content based on active menu index
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
                                        if (state.successMessage ==
                                            'Service created successfully') {
                                          _resetServiceForm();
                                        }
                                      }
                                      if (state.error != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(state.error!),
                                              backgroundColor: Colors.red),
                                        );
                                        setState(() {
                                          _isSavingService = false;
                                        });
                                      }
                                    },
                                    builder: (context, state) {
                                      return _buildActiveTabContent(
                                          context, isDark, state);
                                    },
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
        ));
  }

  Widget _buildTopBar(BuildContext context, bool isDark, String token) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                height: 44,
                child: Image.asset('assets/images/AM5 ROYAL TM logo.png'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AM5 ROYAL',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isDark ? Colors.white : const Color(0xFF0D3B66),
                    ),
                  ),
                  Text(
                    'ADMIN PANEL',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: isDark
                          ? AppColors.accentLight
                          : const Color(0xFF0C3D98),
                    ),
                  ),
                ],
              ),
            ],
          ),
          MouseRegion(
            onEnter: (_) => setState(() => _isHoveredLogout = true),
            onExit: (_) => setState(() => _isHoveredLogout = false),
            child: GestureDetector(
              onTap: () {
                context.read<AuthBloc>().add(const AuthEvent.logout());
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _isHoveredLogout
                      ? Colors.redAccent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isHoveredLogout
                        ? Colors.redAccent
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_outlined,
                      color: _isHoveredLogout
                          ? Colors.redAccent
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF6C84A5)),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _isHoveredLogout
                            ? Colors.redAccent
                            : (isDark ? Colors.white : const Color(0xFF0D3B66)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDark) {
    final menuItems = [
      {'title': 'Overview Analytics', 'icon': Icons.analytics_outlined},
      {'title': 'Employee Directory', 'icon': Icons.people_outline},
      {'title': 'Vendor Approvals', 'icon': Icons.verified_user_outlined},
      {'title': 'Services Management', 'icon': Icons.design_services_outlined},
      {
        'title': 'Withdrawal Requests',
        'icon': Icons.account_balance_wallet_outlined
      },
      {'title': 'Company Website Leads', 'icon': Icons.language_outlined},
      {
        'title': 'Company Application Leads',
        'icon': Icons.phone_android_outlined
      },
    ];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(menuItems.length, (index) {
          final item = menuItems[index];
          final isActive = _activeMenuIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() => _activeMenuIndex = index);
                  if (index == 4) {
                    _fetchWithdrawalRequests();
                  } else if (index == 5) {
                    _fetchWebsiteLeads();
                  } else if (index == 6) {
                    _fetchMobileLeads();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isDark
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : AppColors.primaryContainer.withValues(alpha: 0.7))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? (isDark
                              ? AppColors.accent
                              : AppColors.primary.withValues(alpha: 0.15))
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isActive
                            ? (isDark
                                ? AppColors.accentLight
                                : const Color(0xFF0C3D98))
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : const Color(0xFF6C84A5)),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item['title'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w500,
                          color: isActive
                              ? (isDark
                                  ? Colors.white
                                  : const Color(0xFF0D3B66))
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : const Color(0xFF6C84A5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveTabContent(
      BuildContext context, bool isDark, AdminState state) {
    switch (_activeMenuIndex) {
      case 0:
        return _buildOverviewAnalyticsTab(context, isDark, state);
      case 1:
        return _buildEmployeeManagementTab(context, isDark, state);
      case 2:
        return _buildVendorApprovalsTab(context, isDark, state);
      case 3:
        return _buildServicesManagementTab(context, isDark, state);
      case 4:
        return _buildWithdrawalsTab(context, isDark);
      case 5:
        return _buildWebsiteLeadsTab(context, isDark);
      case 6:
        return _buildMobileLeadsTab(context, isDark);
      default:
        return _buildOverviewAnalyticsTab(context, isDark, state);
    }
  }

  // ==========================================
  // TAB 1: OVERVIEW ANALYTICS
  // ==========================================
  Widget _buildOverviewAnalyticsTab(
      BuildContext context, bool isDark, AdminState state) {
    if (state.isLoading && state.stats == null) {
      return Center(
        child: CircularProgressIndicator(
            color: isDark ? AppColors.accent : AppColors.primary),
      );
    }

    final stats = state.stats;
    final activeVendors =
        stats?.totalVendors ?? 0; // Using total vendors for now
    final activeEmployees = stats?.totalEmployees ?? 0;
    final totalSales = stats?.totalSales ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Overview Analytics',
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D3B66)),
              ),
            ),
            const SizedBox(width: 16),
            _buildSecureTag(isDark),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Detailed system performance counters, referral milestones, and platform scaling metrics.',
          style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF6C84A5)),
        ),
        const SizedBox(height: 24),

        // Grid cards
        Row(
          children: [
            Expanded(
                child: _buildMetricCard(
                    'Total Vendors',
                    '$activeVendors',
                    'Currently registered vendors',
                    Icons.verified_user_outlined,
                    isDark)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildMetricCard(
                    'Total Sales',
                    '₹${totalSales.toStringAsFixed(0)}',
                    'Overall platform revenue',
                    Icons.attach_money_outlined,
                    isDark)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildMetricCard(
                    'Active Employees',
                    '$activeEmployees',
                    'Telecallers & Marketing Reps',
                    Icons.badge_outlined,
                    isDark)),
          ],
        ),
        const SizedBox(height: 24),

        // Overall platform growth line chart
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Platform Scaling & Onboarding Growth',
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0D3B66)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monthly vendor onboardings and customer signup rates (Jan - Jun)',
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF6C84A5)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 8),
                    child: CustomPlatformChart(
                        monthlyGrowth: stats?.monthlyGrowth ?? []),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, String subText, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : const Color(0xFFEEF6FD),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: isDark ? AppColors.accentLight : const Color(0xFF0C3D98),
                size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF6C84A5)),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0D3B66)),
                ),
                const SizedBox(height: 2),
                Text(
                  subText,
                  style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: isDark ? Colors.grey : const Color(0xFF6C84A5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: EMPLOYEE MANAGEMENT
  // ==========================================
  Widget _buildEmployeeManagementTab(
      BuildContext context, bool isDark, AdminState state) {
    if (state.isLoading && state.employees == null) {
      return Center(
        child: CircularProgressIndicator(
            color: isDark ? AppColors.accent : AppColors.primary),
      );
    }

    final authState = context.read<AuthBloc>().state;
    final String? loggedInEmail = authState.maybeWhen(
      success: (message, auth) => auth.email,
      orElse: () => null,
    );
    final String? loggedInId = authState.maybeWhen(
      success: (message, auth) => auth.id,
      orElse: () => null,
    );

    final employees = (state.employees ?? []).where((emp) {
      final isSelf = (loggedInEmail != null &&
              emp.email.toLowerCase() == loggedInEmail.toLowerCase()) ||
          (loggedInId != null && emp.id.toString() == loggedInId) ||
          (emp.role.toLowerCase() == 'admin');
      return !isSelf;
    }).toList();

    // Sort employees by points desc for leaderboard
    final leaderboard = List.from(employees)
      ..sort((a, b) => (b.points).compareTo(a.points));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Employee Directory & Referral Leaderboard',
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D3B66)),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddEmployeeDialog(context, isDark),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add Employee',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C3D98),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Split screen: Left Employee table, Right Leaderboard
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Directory
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: employees.length,
                    separatorBuilder: (_, __) => Divider(
                        color: isDark ? Colors.white10 : Colors.black12,
                        height: 20),
                    itemBuilder: (context, index) {
                      final emp = employees[index];
                      final isSuspended = emp.status == 'Suspended';

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : const Color(0xFFEEF6FD),
                            child: Text(
                                emp.email.isNotEmpty
                                    ? emp.email[0].toUpperCase()
                                    : 'U',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0C3D98))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(emp.email,
                                    style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0D3B66))),
                                const SizedBox(height: 2),
                                Text('${emp.role} | ${emp.phoneNumber ?? ''}',
                                    style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : const Color(0xFF6C84A5))),
                              ],
                            ),
                          ),
                          // Stats
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${emp.points} pts',
                                  style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.accentLight
                                          : const Color(0xFF0C3D98))),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSuspended
                                      ? (isDark
                                          ? Colors.redAccent
                                              .withValues(alpha: 0.15)
                                          : const Color(0xFFFEE2E2))
                                      : (isDark
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : const Color(0xFFD1FAE5)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  emp.status,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSuspended
                                        ? Colors.redAccent
                                        : const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          // Actions dropdown trigger
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert,
                                color: isDark ? Colors.white54 : Colors.grey),
                            onSelected: (value) {
                              if (value == 'toggle') {
                                context
                                    .read<AdminBloc>()
                                    .add(UpdateEmployeeAccountStatus(
                                      emp.id,
                                      isSuspended ? 'Active' : 'Suspended',
                                    ));
                              } else if (value == 'edit') {
                                _showEditEmployeeDialog(context, isDark, emp);
                              } else if (value == 'delete') {
                                // Add delete logic or leave as is if no API endpoint yet
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit Employee'),
                              ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Text(isSuspended
                                    ? 'Activate Employee'
                                    : 'Suspend Employee'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete Account',
                                    style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Right Leaderboard
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_outlined,
                              color: Color(0xFFD4A33A), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Referral Leaderboard',
                            style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0D3B66)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: leaderboard.length,
                          itemBuilder: (context, index) {
                            final emp = leaderboard[index];
                            final rank = index + 1;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: rank == 1
                                          ? const Color(0xFFD4A33A)
                                              .withValues(alpha: 0.2)
                                          : (isDark
                                              ? Colors.white10
                                              : Colors.black12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$rank',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: rank == 1
                                              ? const Color(0xFFD4A33A)
                                              : (isDark
                                                  ? Colors.white70
                                                  : Colors.black87),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      emp.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: rank == 1
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0D3B66),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${emp.points} pts',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: rank == 1
                                          ? const Color(0xFFD4A33A)
                                          : (isDark
                                              ? AppColors.accentLight
                                              : const Color(0xFF0C3D98)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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

  void _showAddEmployeeDialog(BuildContext context, bool isDark) {
    _employeeNameController.clear();
    _employeeEmailController.clear();
    _employeePhoneController.clear();
    _employeePasswordController.clear();

    InputDecoration buildDialogFieldDecoration({
      required String label,
      required IconData prefixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C84A5),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: isDark
              ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
              : const Color(0xFF6C84A5),
          size: 20,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : const Color(0xFFF3F7FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF0C3D98),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1,
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider<AdminBloc>.value(
          value: context.read<AdminBloc>(),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3D98).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Color(0xFF0C3D98),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Add New Employee',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0D3B66),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Configure credentials & system role mapping',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: isDark
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
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      TextField(
                        controller: _employeeNameController,
                        style: GoogleFonts.outfit(fontSize: 15),
                        decoration: buildDialogFieldDecoration(
                          label: 'Employee Name',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _employeeEmailController,
                        style: GoogleFonts.outfit(fontSize: 15),
                        decoration: buildDialogFieldDecoration(
                          label: 'Email Address',
                          prefixIcon: Icons.mail_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _employeePhoneController,
                        style: GoogleFonts.outfit(fontSize: 15),
                        decoration: buildDialogFieldDecoration(
                          label: 'Phone Number',
                          prefixIcon: Icons.phone_android_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _employeePasswordController,
                        obscureText: true,
                        style: GoogleFonts.outfit(fontSize: 15),
                        decoration: buildDialogFieldDecoration(
                          label: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedEmployeeRole,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color:
                              isDark ? Colors.white : const Color(0xFF0D3B66),
                        ),
                        dropdownColor:
                            isDark ? AppColors.darkSurface : Colors.white,
                        decoration: buildDialogFieldDecoration(
                          label: 'Role',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'verification', child: Text('Verification Department')),
                          DropdownMenuItem(
                              value: 'marketing', child: Text('Marketing Department')),
                          DropdownMenuItem(
                              value: 'developer', child: Text('Developer Department')),
                          DropdownMenuItem(
                              value: 'accounts', child: Text('Accounts Department')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => _selectedEmployeeRole = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actionsPadding:
                    const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                actions: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.white70 : const Color(0xFF4A5568),
                      side: BorderSide(
                        color:
                            isDark ? Colors.white24 : const Color(0xFFCBD5E0),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = _employeeNameController.text.trim();
                      final email = _employeeEmailController.text.trim();
                      if (name.isNotEmpty &&
                          email.isNotEmpty &&
                          _employeePhoneController.text.isNotEmpty &&
                          _employeePasswordController.text.isNotEmpty) {
                        context.read<AdminBloc>().add(
                              CreateEmployeeSubmitted({
                                'first_name': name,
                                'email': email,
                                'phone_number':
                                    _employeePhoneController.text.trim(),
                                'password':
                                    _employeePasswordController.text.trim(),
                                'role': _selectedEmployeeRole,
                              }),
                            );
                        Navigator.pop(context);

                        // Clear controllers
                        _employeeNameController.clear();
                        _employeeEmailController.clear();
                        _employeePhoneController.clear();
                        _employeePasswordController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all fields')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3D98),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor:
                          const Color(0xFF0C3D98).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                    ),
                    child: Text('Create',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showEditEmployeeDialog(
      BuildContext context, bool isDark, AdminEmployee employee) {
    _employeeNameController.text = employee.name;
    _employeeEmailController.text = employee.email;
    _employeePhoneController.text = employee.phoneNumber ?? '';
    _selectedEmployeeRole = employee.role.toLowerCase();

    InputDecoration buildDialogFieldDecoration({
      required String label,
      required IconData prefixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C84A5),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: isDark
              ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
              : const Color(0xFF6C84A5),
          size: 20,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : const Color(0xFFF3F7FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF0C3D98),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1,
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider<AdminBloc>.value(
          value: context.read<AdminBloc>(),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3D98).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Color(0xFF0C3D98),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Edit Employee',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0D3B66),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Update member details & role permissions',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: isDark
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
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      TextField(
                        controller: _employeeNameController,
                        style: GoogleFonts.outfit(fontSize: 15),
                        decoration: buildDialogFieldDecoration(
                          label: 'Employee Name',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _employeeEmailController,
                        style: GoogleFonts.outfit(fontSize: 15),
                        decoration: buildDialogFieldDecoration(
                          label: 'Email Address',
                          prefixIcon: Icons.mail_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _employeePhoneController,
                        style: GoogleFonts.outfit(fontSize: 15),
                        decoration: buildDialogFieldDecoration(
                          label: 'Phone Number',
                          prefixIcon: Icons.phone_android_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedEmployeeRole,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color:
                              isDark ? Colors.white : const Color(0xFF0D3B66),
                        ),
                        dropdownColor:
                            isDark ? AppColors.darkSurface : Colors.white,
                        decoration: buildDialogFieldDecoration(
                          label: 'Role',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'verification', child: Text('Verification Department')),
                          DropdownMenuItem(
                              value: 'marketing', child: Text('Marketing Department')),
                          DropdownMenuItem(
                              value: 'developer', child: Text('Developer Department')),
                          DropdownMenuItem(
                              value: 'accounts', child: Text('Accounts Department')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => _selectedEmployeeRole = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actionsPadding:
                    const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                actions: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.white70 : const Color(0xFF4A5568),
                      side: BorderSide(
                        color:
                            isDark ? Colors.white24 : const Color(0xFFCBD5E0),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = _employeeNameController.text.trim();
                      final email = _employeeEmailController.text.trim();
                      if (name.isNotEmpty &&
                          email.isNotEmpty &&
                          _employeePhoneController.text.isNotEmpty) {
                        context.read<AdminBloc>().add(
                              UpdateEmployeeSubmitted(
                                employee.id,
                                {
                                  'first_name': name,
                                  'email': email,
                                  'phone_number':
                                      _employeePhoneController.text.trim(),
                                  'role': _selectedEmployeeRole,
                                },
                              ),
                            );
                        Navigator.pop(context);

                        // Clear controllers
                        _employeeNameController.clear();
                        _employeeEmailController.clear();
                        _employeePhoneController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all fields')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3D98),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor:
                          const Color(0xFF0C3D98).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                    ),
                    child: Text('Save',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 3: VENDOR APPROVALS & VERIFICATION
  // ==========================================
  Widget _buildVendorApprovalsTab(
      BuildContext context, bool isDark, AdminState state) {
    if (state.isLoading && state.vendors == null) {
      return Center(
        child: CircularProgressIndicator(
            color: isDark ? AppColors.accent : AppColors.primary),
      );
    }

    final vendorsList = (state.vendors ?? []).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Vendor Registration Approvals',
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D3B66)),
              ),
            ),
            const SizedBox(width: 16),
            _buildSecureTag(isDark),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Review submitted KYC documentation, pan-cards, and verify newly onboarded service categories before approval.',
          style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF6C84A5)),
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: TextField(
            controller: _vendorSearchController,
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search vendors by name, mobile or company...',
              hintStyle: GoogleFonts.outfit(
                  color: isDark ? Colors.white54 : Colors.grey[600]),
              prefixIcon: Icon(Icons.search,
                  color: isDark ? Colors.white54 : Colors.grey[600]),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E2433) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              if (_vendorSearchDebounce?.isActive ?? false) {
                _vendorSearchDebounce!.cancel();
              }
              _vendorSearchDebounce =
                  Timer(const Duration(milliseconds: 500), () {
                context
                    .read<AdminBloc>()
                    .add(FetchAdminVendorsList(searchQuery: value));
              });
            },
          ),
        ),
        const SizedBox(height: 24),

        // List
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.white.withValues(alpha: 0.2)),
            ),
            child: vendorsList.isEmpty
                ? Center(
                    child: Text('No vendor registrations found.',
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white60 : Colors.black54)))
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: vendorsList.length,
                    separatorBuilder: (_, __) => Divider(
                        color: isDark ? Colors.white10 : Colors.black12,
                        height: 24),
                    itemBuilder: (context, index) {
                      final vendor = vendorsList[index];
                      final statusLower = vendor.status.toLowerCase();
                      final isPending = statusLower == 'pending' ||
                          statusLower == 'pending approval' ||
                          statusLower == 'temporary_active' ||
                          statusLower == 'temporary active';
                      final isSuspended = statusLower == 'suspended';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : const Color(0xFFEEF6FD),
                                child: Icon(Icons.storefront_outlined,
                                    color: isDark
                                        ? AppColors.accentLight
                                        : const Color(0xFF0C3D98)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(vendor.name,
                                        style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF0D3B66))),
                                    const SizedBox(height: 2),
                                    Text(
                                        'City: ${vendor.city ?? 'Unknown'} | Contact: ${vendor.phoneNumber ?? 'N/A'}\n'
                                        'Email: ${vendor.email ?? 'N/A'} | Telecaller: ${vendor.onboardedByEmployeeName ?? 'N/A'} (ID: ${vendor.employeeId})\n'
                                        'Joined: ${vendor.createdAt.toString().split('.')[0]}\n'
                                        'Docs: ${vendor.documentsUploaded ? 'Uploaded' : 'Pending'} | Payment: ${vendor.hasPayment ? 'Paid' : 'Unpaid'}',
                                        style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : const Color(0xFF6C84A5))),
                                  ],
                                ),
                              ),
                              // Status badge
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPending
                                          ? (isDark
                                              ? Colors.orange
                                                  .withValues(alpha: 0.15)
                                              : const Color(0xFFFEF3C7))
                                          : (isSuspended
                                              ? (isDark
                                                  ? Colors.redAccent
                                                      .withValues(alpha: 0.15)
                                                  : const Color(0xFFFEE2E2))
                                              : (isDark
                                                  ? Colors.green
                                                      .withValues(alpha: 0.15)
                                                  : const Color(0xFFD1FAE5))),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isPending
                                            ? Colors.orange
                                                .withValues(alpha: 0.3)
                                            : (isSuspended
                                                ? Colors.redAccent
                                                    .withValues(alpha: 0.3)
                                                : Colors.green
                                                    .withValues(alpha: 0.3)),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      statusLower == 'temporary_active' ||
                                              statusLower == 'temporary active'
                                          ? 'Temporary Active'
                                          : (statusLower == 'active'
                                              ? 'Account Activated'
                                              : vendor.status),
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isPending
                                            ? Colors.orange
                                            : (isSuspended
                                                ? Colors.redAccent
                                                : const Color(0xFF10B981)),
                                      ),
                                    ),
                                  ),
                                  if (statusLower == 'temporary_active' ||
                                      statusLower == 'temporary active') ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '(Under Verification)',
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Documentation Verification Badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'KYC Verification: ',
                                    style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : const Color(0xFF6C84A5)),
                                  ),
                                  const SizedBox(width: 8),
                                  ..._buildVerificationBadges(
                                      context, vendor, isDark),
                                ],
                              ),
                              // Actions
                              Row(
                                children: [
                                  if (isPending) ...[
                                    TextButton(
                                      onPressed: () {
                                        context
                                            .read<AdminBloc>()
                                            .add(UpdateVendorAccountStatus(
                                              vendor.id,
                                              'Suspended',
                                            ));
                                      },
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.redAccent),
                                      child: Text('Reject',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<AdminBloc>()
                                            .add(UpdateVendorAccountStatus(
                                              vendor.id,
                                              'Active',
                                            ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      child: Text('Approve',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ] else ...[
                                    TextButton(
                                      onPressed: () {
                                        context
                                            .read<AdminBloc>()
                                            .add(UpdateVendorAccountStatus(
                                              vendor.id,
                                              isSuspended
                                                  ? 'Active'
                                                  : 'Suspended',
                                            ));
                                      },
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.redAccent),
                                      child: Text(
                                          isSuspended ? 'Activate' : 'Suspend',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.blue),
                                    onPressed: () {
                                      _showEditVendorDialog(
                                          context, vendor, isDark);
                                    },
                                    tooltip: 'Edit Vendor',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      _showDeleteVendorDialog(
                                          context, vendor, isDark);
                                    },
                                    tooltip: 'Delete Vendor',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildVerificationBadges(
      BuildContext context, AdminVendor vendor, bool isDark) {
    final statusLower = vendor.status.toLowerCase();
    final statusLabel = (statusLower == 'active') ? 'Verified' : 'Pending';

    final Map<String, String> docs = {
      'Aadhaar':
          (vendor.aadhaarNumber != null && vendor.aadhaarNumber!.isNotEmpty)
              ? statusLabel
              : (vendor.documentsUploaded ? statusLabel : 'N/A'),
      'PAN': (vendor.panCardNumber != null && vendor.panCardNumber!.isNotEmpty)
          ? statusLabel
          : (vendor.documentsUploaded ? statusLabel : 'N/A'),
      'GST': (vendor.gstNumber != null && vendor.gstNumber!.isNotEmpty)
          ? statusLabel
          : (vendor.documentsUploaded ? statusLabel : 'N/A'),
    };
    if ((vendor.fssaiLicenseNumber != null &&
            vendor.fssaiLicenseNumber!.isNotEmpty) ||
        vendor.documentsUploaded) {
      docs['FSSAI'] = statusLabel;
    }

    return docs.entries.map((entry) {
      final docName = entry.key;
      final docStatus = entry.value;

      Color badgeBg;
      Color badgeFg;
      if (docStatus == 'Verified') {
        badgeBg = isDark
            ? Colors.green.withValues(alpha: 0.15)
            : const Color(0xFFD1FAE5);
        badgeFg = const Color(0xFF10B981);
      } else if (docStatus == 'Pending') {
        badgeBg = isDark
            ? Colors.orange.withValues(alpha: 0.15)
            : const Color(0xFFFEF3C7);
        badgeFg = Colors.orange;
      } else {
        badgeBg = isDark ? Colors.white10 : Colors.black12;
        badgeFg = isDark ? Colors.white38 : Colors.grey;
      }

      String docValue = '';
      if (docName == 'Aadhaar') docValue = vendor.aadhaarNumber ?? '';
      if (docName == 'PAN') docValue = vendor.panCardNumber ?? '';
      if (docName == 'GST') docValue = vendor.gstNumber ?? '';
      if (docName == 'FSSAI') docValue = vendor.fssaiLicenseNumber ?? '';

      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: InkWell(
          onTap: docStatus == 'N/A'
              ? null
              : () => _handleDocumentBadgeTap(
                  context, vendor.id, docName, docValue, isDark),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: badgeFg.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$docName: $docStatus',
                  style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeFg),
                ),
                if (docStatus != 'N/A') ...[
                  const SizedBox(width: 4),
                  Icon(Icons.open_in_new, size: 10, color: badgeFg),
                ],
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _handleDocumentBadgeTap(BuildContext context, int vendorId,
      String docName, String docValue, bool isDark) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final remoteDataSource = di.sl<AdminRemoteDataSource>();
      final docs = await remoteDataSource.getVendorDocuments(vendorId);
      if (mounted) {
        Navigator.pop(context); // Dismiss loader
      }

      // Map docName to expected backend document_type string
      final String targetTypeLower = docName.toLowerCase();

      // Find document matching the type
      final document = docs.firstWhere(
        (d) {
          final type = (d['document_type'] ?? '').toString().toLowerCase();
          return type.contains(targetTypeLower) ||
              targetTypeLower.contains(type);
        },
        orElse: () => null,
      );

      if (document != null) {
        _showDocumentViewer(context, document, isDark);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'No uploaded scan file found for $docName. Only registration number exists.')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load documents: $e')),
        );
      }
    }
  }

  void _showDocumentViewer(
      BuildContext context, Map<String, dynamic> document, bool isDark) {
    final docId = document['id'];
    final docName = (document['document_type'] ?? '').toString().toUpperCase();
    final docStatus = (document['verification_status'] ?? 'pending').toString();
    final docUrl = document['document_url'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isPending = docStatus == 'pending';

            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Verify Document - $docName',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              content: Container(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Render document scan
                    Container(
                      height: 320,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : const Color(0xFFF7FBFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: docUrl.isNotEmpty && docUrl.startsWith('http')
                            ? Image.network(
                                docUrl,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.broken_image_outlined,
                                            size: 48, color: Colors.grey),
                                        const SizedBox(height: 8),
                                        Text('Failed to load image',
                                            style: GoogleFonts.outfit(
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Text('No scan file available'),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status: ${docStatus.toUpperCase()}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: docStatus == 'approved'
                                ? Colors.green
                                : (docStatus == 'rejected'
                                    ? Colors.red
                                    : Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                if (isPending) ...[
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Show loader
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                      try {
                        final remoteDataSource = di.sl<AdminRemoteDataSource>();
                        await remoteDataSource.updateDocumentStatus(
                            docId, 'rejected');
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Document Rejected successfully!'),
                                backgroundColor: Colors.red),
                          );
                          // Refresh vendor approvals list
                          context
                              .read<AdminBloc>()
                              .add(FetchAdminVendorsList());
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to update status: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject Document'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Show loader
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                      try {
                        final remoteDataSource = di.sl<AdminRemoteDataSource>();
                        await remoteDataSource.updateDocumentStatus(
                            docId, 'approved');
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Document Approved successfully!'),
                                backgroundColor: Colors.green),
                          );
                          // Refresh vendor approvals list
                          context
                              .read<AdminBloc>()
                              .add(FetchAdminVendorsList());
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to update status: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve Document'),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSecureTag(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.accent.withValues(alpha: 0.15)
            : AppColors.accentContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.accent
              : AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            color: isDark ? AppColors.accentLight : AppColors.accentDark,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'SECURE',
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: isDark ? AppColors.accentLight : AppColors.accentDark,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: SERVICES MANAGEMENT
  // ==========================================
  Widget _buildServicesManagementTab(
      BuildContext context, bool isDark, AdminState state) {
    // Fetch main categories once
    if (_mainCategories.isEmpty && _isLoadingCategories) {
      di.sl<MainCategoryApiService>().getMainCategories().then((categories) {
        if (mounted) {
          setState(() {
            _mainCategories = categories;
            _isLoadingCategories = false;
            // Automatically select 'Home' if exists
            try {
              _selectedMainCategory = categories
                  .firstWhere((cat) => cat.name.toLowerCase().contains('home'));
            } catch (e) {
              if (categories.isNotEmpty) {
                _selectedMainCategory = categories.first;
              }
            }

            if (_selectedMainCategory != null) {
              // Fetch subcategories
              di
                  .sl<MainCategoryApiService>()
                  .getSubCategories(_selectedMainCategory!.id)
                  .then((subs) {
                if (mounted) {
                  setState(() {
                    _subCategories = subs;
                    if (subs.isNotEmpty) {
                      _selectedSubCategory = subs.first;
                    }
                  });
                }
              });
            }
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _isLoadingCategories = false;
          });
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Services Management',
          style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D3B66)),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isLoadingCategories)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
                      // Parent Category Dropdown
                      Text(
                        'Parent Category',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF0D3B66)),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<MainCategoryModel>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.grey.shade100,
                          prefixIcon: Icon(
                            Icons.grid_view_rounded,
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF0C3D98),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300,
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
                        ),
                        dropdownColor:
                            isDark ? AppColors.darkSurface : Colors.white,
                        value: _selectedMainCategory,
                        items: _mainCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat.name,
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedMainCategory = val;
                              _selectedSubCategory = null;
                              _subCategories = [];
                            });
                            di
                                .sl<MainCategoryApiService>()
                                .getSubCategories(val.id)
                                .then((subs) {
                              if (mounted) {
                                setState(() {
                                  _subCategories = subs;
                                  if (subs.isNotEmpty) {
                                    _selectedSubCategory = subs.first;
                                  }
                                });
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assign the service to a top-level parent category.',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color:
                                isDark ? Colors.white38 : Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),

                      // Service Subcategory Dropdown
                      Text(
                        'Service Subcategory',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF0D3B66)),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<SubCategoryModel>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.grey.shade100,
                          prefixIcon: Icon(
                            Icons.category_rounded,
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF0C3D98),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300,
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
                        ),
                        dropdownColor:
                            isDark ? AppColors.darkSurface : Colors.white,
                        value: _selectedSubCategory,
                        items: _subCategories.map((sub) {
                          return DropdownMenuItem(
                            value: sub,
                            child: Text(sub.name,
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSubCategory = val;
                          });
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Group the service under a specific organizational subcategory.',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color:
                                isDark ? Colors.white38 : Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),

                      // Service Name
                      Text(
                        'Service Name',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF0D3B66)),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _serviceNameController,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.grey.shade100,
                          prefixIcon: Icon(
                            Icons.drive_file_rename_outline_rounded,
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF0C3D98),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300,
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
                          hintText: 'Enter service name',
                          hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use a consumer-friendly title (e.g., Deep Home Cleaning).',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color:
                                isDark ? Colors.white38 : Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),

                      // Service Cover Image Picker
                      Text(
                        'Service Cover Image',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF0D3B66)),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              _selectedServiceImage = pickedFile;
                            });
                          }
                        },
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300,
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _selectedServiceImage != null
                              ? Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: kIsWeb
                                            ? Image.network(
                                                _selectedServiceImage!.path,
                                                fit: BoxFit.cover)
                                            : Image.file(
                                                File(_selectedServiceImage!
                                                    .path),
                                                fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.edit_rounded,
                                              color: Colors.white, size: 18),
                                          onPressed: () async {
                                            final picker = ImagePicker();
                                            final pickedFile =
                                                await picker.pickImage(
                                                    source:
                                                        ImageSource.gallery);
                                            if (pickedFile != null) {
                                              setState(() {
                                                _selectedServiceImage =
                                                    pickedFile;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 36,
                                      color: isDark
                                          ? Colors.white38
                                          : const Color(0xFF0C3D98),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to select cover image',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Supports PNG, JPG. Recommended 1:1 ratio.',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.white30
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upload a high-quality visual representation photo.',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color:
                                isDark ? Colors.white38 : Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSavingService ||
                                  _selectedMainCategory == null ||
                                  _selectedSubCategory == null ||
                                  _selectedServiceImage == null ||
                                  _serviceNameController.text.trim().isEmpty
                              ? null
                              : () {
                                  setState(() {
                                    _isSavingService = true;
                                  });
                                  final adminBloc =
                                      BlocProvider.of<AdminBloc>(context);
                                  adminBloc.add(
                                    CreateServiceSubmitted(
                                      name: _serviceNameController.text.trim(),
                                      mainCategoryId: _selectedMainCategory!.id,
                                      subCategoryId: _selectedSubCategory!.id,
                                      imagePath: _selectedServiceImage!.path,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C3D98),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                isDark ? Colors.white10 : Colors.grey.shade300,
                            disabledForegroundColor:
                                isDark ? Colors.white24 : Colors.grey.shade500,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isSavingService
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Publish Service',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditVendorDialog(
      BuildContext context, AdminVendor vendor, bool isDark) {
    final nameController = TextEditingController(text: vendor.name);
    final emailController = TextEditingController(text: vendor.email);
    final phoneController = TextEditingController(text: vendor.phoneNumber);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Edit Vendor',
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            TextField(
              controller: emailController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            TextField(
              controller: phoneController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(
                    UpdateVendorSubmitted(vendor.id, {
                      'name': nameController.text,
                      'email': emailController.text,
                      'phone_number': phoneController.text,
                    }),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteVendorDialog(
      BuildContext context, AdminVendor vendor, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Delete Vendor',
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text(
          'Are you sure you want to delete vendor "${vendor.name}"?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<AdminBloc>().add(
                    DeleteVendorSubmitted(vendor.id),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchWithdrawalRequests() async {
    setState(() {
      _isLoadingWithdrawals = true;
    });
    try {
      final remoteDataSource = di.sl<AdminRemoteDataSource>();
      final list = await remoteDataSource.getWithdrawalRequests();
      if (mounted) {
        setState(() {
          _withdrawalRequests = list;
          _isLoadingWithdrawals = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWithdrawals = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load withdrawals: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _approveWithdrawal(int id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final remoteDataSource = di.sl<AdminRemoteDataSource>();
      await remoteDataSource.approveWithdrawalRequest(id);
      if (mounted) {
        Navigator.pop(context); // Dismiss loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Withdrawal marked as Sent!'),
              backgroundColor: Colors.green),
        );
        _fetchWithdrawalRequests(); // Reload
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to approve withdrawal: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _fetchCompanyLeads({
    bool resetPage = false,
    String? leadSource,
  }) async {
    if (resetPage) {
      _companyLeadsSkip = 0;
    }
    final source = leadSource ??
        (_activeMenuIndex == 6 ? 'company_mobile' : 'company_website');
    setState(() {
      _isLoadingCompanyLeads = true;
    });
    try {
      final remoteDataSource = di.sl<AdminRemoteDataSource>();
      final startStr = _companyLeadsStartDate != null
          ? _companyLeadsStartDate!.toIso8601String().split('T')[0]
          : null;
      final endStr = _companyLeadsEndDate != null
          ? _companyLeadsEndDate!.toIso8601String().split('T')[0]
          : null;
      final response = await remoteDataSource.getCompanyLeads(
        startDate: startStr,
        endDate: endStr,
        leadSource: source,
        skip: _companyLeadsSkip,
        limit: _companyLeadsLimit,
      );
      if (mounted) {
        setState(() {
          _companyLeads = response.leads;
          _companyLeadsTotalCount = response.total;
          _isLoadingCompanyLeads = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _companyLeads = [];
          _companyLeadsTotalCount = 0;
          _isLoadingCompanyLeads = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load company leads: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectCompanyLeadsDateRange(
      BuildContext context, bool isDark) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
      initialDateRange:
          _companyLeadsStartDate != null && _companyLeadsEndDate != null
              ? DateTimeRange(
                  start: _companyLeadsStartDate!, end: _companyLeadsEndDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF10B981),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                    secondary: Color(0xFF10B981),
                  ),
                  dialogBackgroundColor: const Color(0xFF0F172A),
                  scaffoldBackgroundColor: const Color(0xFF0F172A),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF0C3D98),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF16315D),
                    secondary: Color(0xFF0C3D98),
                  ),
                  dialogBackgroundColor: Colors.white,
                  scaffoldBackgroundColor: Colors.white,
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
        _companyLeadsStartDate = picked.start;
        _companyLeadsEndDate = picked.end;
      });
      _fetchCompanyLeads(resetPage: true);
    }
  }

  void _clearCompanyLeadsDateFilter() {
    setState(() {
      _companyLeadsStartDate = null;
      _companyLeadsEndDate = null;
    });
    _fetchCompanyLeads(resetPage: true);
  }

  Future<void> _assignCompanyLeads() async {
    setState(() {
      _isAssigningLeads = true;
    });
    try {
      final remoteDataSource = di.sl<AdminRemoteDataSource>();
      final result = await remoteDataSource.assignCompanyLeads();
      if (mounted) {
        setState(() {
          _isAssigningLeads = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Leads Assigned',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Text(
              'Successfully assigned ${result.assignedCount} leads to ${result.telecallersCount} active telecallers (up to 10 leads each).',
              style: GoogleFonts.outfit(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _fetchWebsiteLeads(resetPage: true);
                  _fetchMobileLeads(resetPage: true);
                  _fetchCompanyLeads(resetPage: true);
                },
                child: Text('OK', style: GoogleFonts.outfit()),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAssigningLeads = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to assign leads: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildCompanyLeadsTab(BuildContext context, bool isDark,
      {required bool isWebsite}) {
    final title = isWebsite
        ? 'Company Website Leads'
        : 'Company Application Leads';
    final subtitle = isWebsite
        ? 'Unassigned leads from the company website.'
        : 'Unassigned leads from the company application.';

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
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (_isAssigningLeads)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  ElevatedButton.icon(
                    onPressed:
                        _companyLeads.isEmpty ? null : _assignCompanyLeads,
                    icon: const Icon(Icons.assignment_ind_outlined),
                    label: Text('Assign Leads (10/Telecaller)',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _fetchCompanyLeads(
                    resetPage: true,
                    leadSource:
                        isWebsite ? 'company_website' : 'company_mobile',
                  ),
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Date Filter Toolbar
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _selectCompanyLeadsDateRange(context, isDark),
              icon: const Icon(Icons.date_range_outlined, size: 16),
              label: Text(
                _companyLeadsStartDate != null && _companyLeadsEndDate != null
                    ? "${_companyLeadsStartDate!.day}/${_companyLeadsStartDate!.month}/${_companyLeadsStartDate!.year} - ${_companyLeadsEndDate!.day}/${_companyLeadsEndDate!.month}/${_companyLeadsEndDate!.year}"
                    : "Select Date Range",
                style: GoogleFonts.outfit(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : AppColors.primary,
                side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade400),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (_companyLeadsStartDate != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _clearCompanyLeadsDateFilter,
                icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                label: Text("Clear Filter",
                    style: GoogleFonts.outfit(color: Colors.red, fontSize: 13)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _isLoadingCompanyLeads
              ? Center(
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.accent : AppColors.primary,
                  ),
                )
              : _companyLeads.isEmpty
                  ? Center(
                      child: Text(
                        'No unassigned leads found.',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                  columns: [
                                    DataColumn(
                                        label: Text('Business Name',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Owner Name',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Phone Number',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Source',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('City',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Payment Status',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Feedback',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Registration Date',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                  rows: _companyLeads.map((lead) {
                                    final dateStr = lead.createdAt != null
                                        ? "${lead.createdAt!.day}/${lead.createdAt!.month}/${lead.createdAt!.year}"
                                        : 'N/A';

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(lead.businessName,
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w600))),
                                        DataCell(Text(
                                            "${lead.firstName} ${lead.lastName}"
                                                .trim(),
                                            style: GoogleFonts.outfit())),
                                        DataCell(Text(lead.phoneNumber ?? 'N/A',
                                            style: GoogleFonts.outfit())),
                                        DataCell(Text(
                                            lead.leadSource == 'company_mobile'
                                                ? 'Application'
                                                : (lead.leadSource ==
                                                        'company_website'
                                                    ? 'Website'
                                                    : (lead.leadSource ??
                                                        'Company')),
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w600))),
                                        DataCell(Text(lead.city,
                                            style: GoogleFonts.outfit())),
                                        DataCell(Text(lead.paymentInfo ?? 'N/A',
                                            style: GoogleFonts.outfit())),
                                        DataCell(Text(lead.feedback ?? 'N/A',
                                            style: GoogleFonts.outfit())),
                                        DataCell(Text(dateStr,
                                            style: GoogleFonts.outfit())),
                                      ],
                                    );
                                  }).toList(),
                              ),
                            ),
                          ),
                        ),
                        // Pagination Footer
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Showing ${_companyLeadsSkip + 1} - ${(_companyLeadsSkip + _companyLeads.length).clamp(0, _companyLeadsTotalCount)} of $_companyLeadsTotalCount",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: _companyLeadsSkip == 0
                                      ? null
                                      : () {
                                          setState(() {
                                            _companyLeadsSkip =
                                                (_companyLeadsSkip -
                                                        _companyLeadsLimit)
                                                    .clamp(0, double.infinity)
                                                    .toInt();
                                          });
                                          _fetchCompanyLeads();
                                        },
                                  color:
                                      isDark ? Colors.white : AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: (_companyLeadsSkip +
                                              _companyLeadsLimit) >=
                                          _companyLeadsTotalCount
                                      ? null
                                      : () {
                                          setState(() {
                                            _companyLeadsSkip +=
                                                _companyLeadsLimit;
                                          });
                                          _fetchCompanyLeads();
                                        },
                                  color:
                                      isDark ? Colors.white : AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalsTab(BuildContext context, bool isDark) {
    if (_isLoadingWithdrawals) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? AppColors.accent : AppColors.primary,
        ),
      );
    }

    if (_withdrawalRequests.isEmpty) {
      return Center(
        child: Text(
          'No withdrawal requests found.',
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Withdrawal Requests',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchWithdrawalRequests,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(
                      label: Text('Name',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Amount',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Bank Details',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Status',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Action',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                ],
                rows: _withdrawalRequests.map((req) {
                  final isPending = req['status'] == 'pending';
                  final bankInfo = "Name: ${req['bank_account_name'] ?? ''}\n"
                      "Bank: ${req['bank_name'] ?? ''}\n"
                      "A/C: ${req['bank_account_number'] ?? ''}\n"
                      "IFSC: ${req['bank_ifsc_code'] ?? ''}";

                  return DataRow(
                    cells: [
                      DataCell(Text(req['employee_name'] ?? '',
                          style: GoogleFonts.outfit())),
                      DataCell(Text('₹${req['amount']}',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            bankInfo,
                            style: GoogleFonts.outfit(fontSize: 12),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPending
                                ? Colors.amber.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPending ? 'Pending' : 'Sent',
                            style: GoogleFonts.outfit(
                              color: isPending
                                  ? Colors.amber.shade800
                                  : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        isPending
                            ? ElevatedButton.icon(
                                onPressed: () => _approveWithdrawal(req['id']),
                                icon: const Icon(Icons.send, size: 14),
                                label: const Text('Sent'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                              )
                            : const Text('Credited',
                                style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // WEBSITE LEADS: Fetch + UI
  // ==========================================

  Future<void> _fetchWebsiteLeads({bool resetPage = false}) async {
    if (resetPage) _websiteLeadsSkip = 0;
    setState(() => _isLoadingWebsiteLeads = true);
    try {
      final ds = di.sl<AdminRemoteDataSource>();
      final startStr = _websiteLeadsStartDate?.toIso8601String().split('T')[0];
      final endStr = _websiteLeadsEndDate?.toIso8601String().split('T')[0];
      final res = await ds.getWebsiteLeads(
        search: _websiteSearchController.text.trim(),
        status: _websiteLeadsStatusFilter,
        startDate: startStr,
        endDate: endStr,
        skip: _websiteLeadsSkip,
        limit: _websiteLeadsLimit,
      );
      if (mounted) {
        setState(() {
          _websiteLeads = res.leads;
          _websiteLeadsTotalCount = res.total;
          _isLoadingWebsiteLeads = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _websiteLeads = [];
          _websiteLeadsTotalCount = 0;
          _isLoadingWebsiteLeads = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load website leads: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildWebsiteLeadsTab(BuildContext context, bool isDark) {
    return _buildSourceLeadsTab(
      context: context,
      isDark: isDark,
      title: 'Company Website Leads',
      subtitle: 'Leads from company website registrations',
      leads: _websiteLeads,
      isLoading: _isLoadingWebsiteLeads,
      totalCount: _websiteLeadsTotalCount,
      skip: _websiteLeadsSkip,
      limit: _websiteLeadsLimit,
      startDate: _websiteLeadsStartDate,
      endDate: _websiteLeadsEndDate,
      statusFilter: _websiteLeadsStatusFilter,
      searchController: _websiteSearchController,
      onSearch: (val) {
        _websiteSearchDebounce?.cancel();
        _websiteSearchDebounce = Timer(const Duration(milliseconds: 500), () {
          _fetchWebsiteLeads(resetPage: true);
        });
        setState(() {});
      },
      onStatusChanged: (val) {
        setState(() => _websiteLeadsStatusFilter = val);
        _fetchWebsiteLeads(resetPage: true);
      },
      onDatePick: () => _pickDateRange(
        context,
        isDark,
        onPicked: (start, end) {
          setState(() {
            _websiteLeadsStartDate = start;
            _websiteLeadsEndDate = end;
          });
          _fetchWebsiteLeads(resetPage: true);
        },
      ),
      onClearDate: () {
        setState(() {
          _websiteLeadsStartDate = null;
          _websiteLeadsEndDate = null;
        });
        _fetchWebsiteLeads(resetPage: true);
      },
      onPrevPage: () {
        setState(() {
          _websiteLeadsSkip =
              (_websiteLeadsSkip - _websiteLeadsLimit).clamp(0, double.infinity).toInt();
        });
        _fetchWebsiteLeads();
      },
      onNextPage: () {
        setState(() => _websiteLeadsSkip += _websiteLeadsLimit);
        _fetchWebsiteLeads();
      },
      onRefresh: () => _fetchWebsiteLeads(resetPage: true),
    );
  }

  // ==========================================
  // MOBILE LEADS: Fetch + UI
  // ==========================================

  Future<void> _fetchMobileLeads({bool resetPage = false}) async {
    if (resetPage) _mobileLeadsSkip = 0;
    setState(() => _isLoadingMobileLeads = true);
    try {
      final ds = di.sl<AdminRemoteDataSource>();
      final startStr = _mobileLeadsStartDate?.toIso8601String().split('T')[0];
      final endStr = _mobileLeadsEndDate?.toIso8601String().split('T')[0];
      final res = await ds.getMobileLeads(
        search: _mobileSearchController.text.trim(),
        status: _mobileLeadsStatusFilter,
        startDate: startStr,
        endDate: endStr,
        skip: _mobileLeadsSkip,
        limit: _mobileLeadsLimit,
      );
      if (mounted) {
        setState(() {
          _mobileLeads = res.leads;
          _mobileLeadsTotalCount = res.total;
          _isLoadingMobileLeads = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mobileLeads = [];
          _mobileLeadsTotalCount = 0;
          _isLoadingMobileLeads = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load mobile leads: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildMobileLeadsTab(BuildContext context, bool isDark) {
    return _buildSourceLeadsTab(
      context: context,
      isDark: isDark,
      title: 'Company Application Leads',
      subtitle: 'Leads from company application registrations',
      leads: _mobileLeads,
      isLoading: _isLoadingMobileLeads,
      totalCount: _mobileLeadsTotalCount,
      skip: _mobileLeadsSkip,
      limit: _mobileLeadsLimit,
      startDate: _mobileLeadsStartDate,
      endDate: _mobileLeadsEndDate,
      statusFilter: _mobileLeadsStatusFilter,
      searchController: _mobileSearchController,
      onSearch: (val) {
        _mobileSearchDebounce?.cancel();
        _mobileSearchDebounce = Timer(const Duration(milliseconds: 500), () {
          _fetchMobileLeads(resetPage: true);
        });
        setState(() {});
      },
      onStatusChanged: (val) {
        setState(() => _mobileLeadsStatusFilter = val);
        _fetchMobileLeads(resetPage: true);
      },
      onDatePick: () => _pickDateRange(
        context,
        isDark,
        onPicked: (start, end) {
          setState(() {
            _mobileLeadsStartDate = start;
            _mobileLeadsEndDate = end;
          });
          _fetchMobileLeads(resetPage: true);
        },
      ),
      onClearDate: () {
        setState(() {
          _mobileLeadsStartDate = null;
          _mobileLeadsEndDate = null;
        });
        _fetchMobileLeads(resetPage: true);
      },
      onPrevPage: () {
        setState(() {
          _mobileLeadsSkip =
              (_mobileLeadsSkip - _mobileLeadsLimit).clamp(0, double.infinity).toInt();
        });
        _fetchMobileLeads();
      },
      onNextPage: () {
        setState(() => _mobileLeadsSkip += _mobileLeadsLimit);
        _fetchMobileLeads();
      },
      onRefresh: () => _fetchMobileLeads(resetPage: true),
    );
  }

  // ==========================================
  // SHARED LEAD TAB BUILDER (website & mobile)
  // ==========================================
  Widget _buildSourceLeadsTab({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required List<CompanyLeadModel> leads,
    required bool isLoading,
    required int totalCount,
    required int skip,
    required int limit,
    required DateTime? startDate,
    required DateTime? endDate,
    required String? statusFilter,
    required TextEditingController searchController,
    required void Function(String) onSearch,
    required void Function(String?) onStatusChanged,
    required VoidCallback onDatePick,
    required VoidCallback onClearDate,
    required VoidCallback onPrevPage,
    required VoidCallback onNextPage,
    required VoidCallback onRefresh,
  }) {
    final statusOptions = ['', 'active', 'pending', 'blocked'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF6C84A5))),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isAssigningLeads)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: leads.isEmpty ? null : _assignCompanyLeads,
                    icon: const Icon(Icons.assignment_ind_outlined),
                    label: Text('Assign Leads (10/Telecaller)',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Search + Status + Date filters
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            // Search box
            SizedBox(
              width: 240,
              child: TextField(
                controller: searchController,
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: 'Search name, phone, city...',
                  hintStyle: GoogleFonts.outfit(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.6),
                ),
                style: GoogleFonts.outfit(fontSize: 13),
              ),
            ),

            // Status dropdown
            DropdownButtonHideUnderline(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isDark ? Colors.white24 : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.6),
                ),
                child: DropdownButton<String?>(
                  value: statusFilter,
                  hint: Text('All Statuses',
                      style: GoogleFonts.outfit(fontSize: 13)),
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  items: statusOptions.map((s) {
                    return DropdownMenuItem<String?>(
                      value: s.isEmpty ? null : s,
                      child: Text(s.isEmpty ? 'All Statuses' : s,
                          style: GoogleFonts.outfit(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: onStatusChanged,
                ),
              ),
            ),

            // Date picker
            OutlinedButton.icon(
              onPressed: onDatePick,
              icon: const Icon(Icons.date_range_outlined, size: 16),
              label: Text(
                startDate != null && endDate != null
                    ? '${startDate.day}/${startDate.month}/${startDate.year} – ${endDate.day}/${endDate.month}/${endDate.year}'
                    : 'Select Date Range',
                style: GoogleFonts.outfit(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : AppColors.primary,
                side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade400),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (startDate != null)
              TextButton.icon(
                onPressed: onClearDate,
                icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                label: Text('Clear',
                    style: GoogleFonts.outfit(
                        color: Colors.red, fontSize: 13)),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Table
        Expanded(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: isDark ? AppColors.accent : AppColors.primary))
              : leads.isEmpty
                  ? Center(
                      child: Text('No leads found.',
                          style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.black54)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columns: [
                                  DataColumn(
                                      label: Text('Business Name',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Owner Name',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Phone',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('City',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Status',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Assigned To',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Payment',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Feedback',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Registered',
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold))),
                                ],
                                rows: leads.map((lead) {
                                  final dateStr = lead.createdAt != null
                                      ? '${lead.createdAt!.day}/${lead.createdAt!.month}/${lead.createdAt!.year}'
                                      : 'N/A';
                                  final statusColor = lead.status == 'active'
                                      ? Colors.green
                                      : lead.status == 'blocked'
                                          ? Colors.red
                                          : Colors.orange;
                                  return DataRow(cells: [
                                    DataCell(Text(lead.businessName,
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600))),
                                    DataCell(Text(
                                        '${lead.firstName} ${lead.lastName}'
                                            .trim(),
                                        style: GoogleFonts.outfit())),
                                    DataCell(Text(lead.phoneNumber ?? 'N/A',
                                        style: GoogleFonts.outfit())),
                                    DataCell(Text(lead.city,
                                        style: GoogleFonts.outfit())),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                              alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(lead.status ?? 'N/A',
                                            style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                color: statusColor,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    DataCell(Text(
                                        lead.assignedTelecallerName ?? 'Unassigned',
                                        style: GoogleFonts.outfit(
                                            color: lead.assignedTelecallerName !=
                                                    null
                                                ? (isDark
                                                    ? Colors.white
                                                    : const Color(0xFF0D3B66))
                                                : Colors.grey))),
                                    DataCell(Text(lead.paymentInfo ?? 'N/A',
                                        style: GoogleFonts.outfit())),
                                    DataCell(Text(lead.feedback ?? 'N/A',
                                        style: GoogleFonts.outfit())),
                                    DataCell(Text(dateStr,
                                        style: GoogleFonts.outfit())),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        // Pagination
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing ${skip + 1}–${(skip + leads.length).clamp(0, totalCount)} of $totalCount',
                              style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: skip == 0 ? null : onPrevPage,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: (skip + limit) >= totalCount
                                      ? null
                                      : onNextPage,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  // Shared date range picker helper
  Future<void> _pickDateRange(
    BuildContext context,
    bool isDark, {
    required void Function(DateTime start, DateTime end) onPicked,
  }) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: isDark
            ? ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF10B981),
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E293B),
                  onSurface: Colors.white,
                ),
              )
            : ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF0C3D98),
                  onPrimary: Colors.white,
                ),
              ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 550),
            child: child,
          ),
        ),
      ),
    );
    if (picked != null) {
      onPicked(picked.start, picked.end);
    }
  }
}

// ==========================================
// CUSTOM VECTOR LINE CHART (GROWTH GRAPH)
// ==========================================
class CustomPlatformChart extends StatelessWidget {
  final List<dynamic> monthlyGrowth;
  const CustomPlatformChart({super.key, required this.monthlyGrowth});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomPaint(
      size: Size.infinite,
      painter: CurveChartPainter(isDark: isDark, monthlyGrowth: monthlyGrowth),
    );
  }
}

class CurveChartPainter extends CustomPainter {
  final bool isDark;
  final List<dynamic> monthlyGrowth;

  CurveChartPainter({required this.isDark, required this.monthlyGrowth});

  @override
  void paint(Canvas canvas, Size size) {
    if (monthlyGrowth.isEmpty) return;

    double maxVal = 10.0;
    for (var item in monthlyGrowth) {
      final double val = (item['count'] ?? 0).toDouble();
      if (val > maxVal) {
        maxVal = val;
      }
    }

    final double stepX = monthlyGrowth.length > 1
        ? size.width / (monthlyGrowth.length - 1)
        : size.width;
    final List<Offset> points = [];
    for (int i = 0; i < monthlyGrowth.length; i++) {
      final double x = i * stepX;
      final double val = (monthlyGrowth[i]['count'] ?? 0).toDouble();
      final double y = size.height - (val / maxVal) * (size.height * 0.7);
      points.add(Offset(x, y));
    }

    // Draw grid background lines
    final gridPaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Prepare line path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
          controlPoint2.dy, p2.dx, p2.dy);
    }

    // Fill area under curve
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0.0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF2E8BF0).withValues(alpha: 0.35),
          const Color(0xFF0C3D98).withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw main curve stroke line
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2E8BF0), Color(0xFF0C3D98)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw dots at points
    final dotPaintOuter = Paint()
      ..color = const Color(0xFF2E8BF0)
      ..style = PaintingStyle.fill;

    final dotPaintInner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 6.0, dotPaintOuter);
      canvas.drawCircle(point, 3.0, dotPaintInner);
    }

    // Draw Text labels for months
    final textStyle = TextStyle(
      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C84A5),
      fontSize: 10,
      fontFamily: 'Outfit',
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < monthlyGrowth.length; i++) {
      final x = points[i].dx - 10;
      final y = size.height + 6.0;
      final monthName = monthlyGrowth[i]['month'] ?? '';

      final textSpan = TextSpan(text: monthName, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CurveChartPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.monthlyGrowth != monthlyGrowth;
  }
}
