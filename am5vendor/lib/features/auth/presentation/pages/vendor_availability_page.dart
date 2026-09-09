import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/onboarding_session_guard.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../products/data/models/product_model.dart';
import '../bloc/vendor_availability_bloc.dart';
import '../bloc/vendor_availability_event.dart';
import '../bloc/vendor_availability_state.dart';
import '../../domain/entities/vendor_availability.dart';

class VendorAvailabilityPage extends StatelessWidget {
  final int mainCategoryId;
  final String mainCategoryName;
  final List<SubCategoryItem> selectedSubCategories;
  final List<SubSubCategoryItem> selectedServiceTypes;
  final String firstName;
  final String lastName;
  final String businessName;
  final bool isSingleService;

  final bool navigateToSubscriptionOnSave;

  const VendorAvailabilityPage({
    super.key,
    this.mainCategoryId = 0,
    this.mainCategoryName = '',
    this.selectedSubCategories = const [],
    this.selectedServiceTypes = const [],
    this.firstName = '',
    this.lastName = '',
    this.businessName = '',
    this.isSingleService = true,
    this.navigateToSubscriptionOnSave = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<VendorAvailabilityBloc>()..add(const GetVendorAvailabilityEvent()),
      child: VendorAvailabilityView(
        mainCategoryId: mainCategoryId,
        mainCategoryName: mainCategoryName,
        selectedSubCategories: selectedSubCategories,
        selectedServiceTypes: selectedServiceTypes,
        firstName: firstName,
        lastName: lastName,
        businessName: businessName,
        isSingleService: isSingleService,
        navigateToSubscriptionOnSave: navigateToSubscriptionOnSave,
      ),
    );
  }
}

class VendorAvailabilityView extends StatefulWidget {
  final int mainCategoryId;
  final String mainCategoryName;
  final List<SubCategoryItem> selectedSubCategories;
  final List<SubSubCategoryItem> selectedServiceTypes;
  final String firstName;
  final String lastName;
  final String businessName;
  final bool isSingleService;
  final bool navigateToSubscriptionOnSave;

  const VendorAvailabilityView({
    super.key,
    required this.mainCategoryId,
    required this.mainCategoryName,
    required this.selectedSubCategories,
    required this.selectedServiceTypes,
    required this.firstName,
    required this.lastName,
    required this.businessName,
    required this.isSingleService,
    this.navigateToSubscriptionOnSave = false,
  });

  @override
  State<VendorAvailabilityView> createState() => _VendorAvailabilityViewState();
}

class _VendorAvailabilityViewState extends State<VendorAvailabilityView> {
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  void _saveChanges(
      BuildContext context, List<VendorAvailability> availabilities) {
    context
        .read<VendorAvailabilityBloc>()
        .add(UpdateVendorAvailabilityEvent(availabilities: availabilities));
  }

  void _handleBackNav(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(
        AppRoutes.vendorRegistration,
        extra: {
          'mainCategoryId': widget.mainCategoryId,
          'mainCategoryName': widget.mainCategoryName,
          'selectedSubCategories': widget.selectedSubCategories,
          'selectedServiceTypes': widget.selectedServiceTypes,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackNav(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Working Hours',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onPressed: () => _handleBackNav(context),
          ),
        actions: [
          BlocBuilder<VendorAvailabilityBloc, VendorAvailabilityState>(
            builder: (context, state) {
              final isSaving =
                  state is VendorAvailabilityLoaded && state.isSaving;
              final canSave =
                  (state is VendorAvailabilityLoaded && !isSaving) ||
                      state is VendorAvailabilityUpdateSuccess;
              final availabilities = state is VendorAvailabilityLoaded
                  ? state.availabilities
                  : (state is VendorAvailabilityUpdateSuccess
                      ? state.availabilities
                      : null);
              return Padding(
                padding:
                    const EdgeInsets.only(right: 16.0, top: 10.0, bottom: 10.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    gradient: canSave ? AppColors.accentGradient : null,
                    color: canSave
                        ? null
                        : (isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: canSave && availabilities != null
                        ? () => _saveChanges(context, availabilities)
                        : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Save',
                            style: GoogleFonts.outfit(
                              color: canSave
                                  ? Colors.white
                                  : (isDark ? Colors.white38 : Colors.black38),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              );
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Splash background
          Positioned.fill(
            child: Image.asset(
              'assets/images/water.png',
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.45),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark
                        ? Colors.black.withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.4),
                    isDark
                        ? Colors.black.withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child:
                BlocConsumer<VendorAvailabilityBloc, VendorAvailabilityState>(
              listener: (context, state) {
                if (state is VendorAvailabilityError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text(state.message)),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is VendorAvailabilityUpdateSuccess) {
                  OnboardingSessionGuard.instance.unlockOnForwardProgress();
                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Schedule updated successfully!'),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  if (widget.navigateToSubscriptionOnSave) {
                    context.go(
                      '${AppRoutes.subscription}?r=${DateTime.now().millisecondsSinceEpoch}',
                      extra: {
                        'fromOnboarding': true,
                        'selectedSubCategories': widget.selectedSubCategories,
                      },
                    );
                  } else {
                    context.go(
                      AppRoutes.businessRegistration,
                      extra: {
                        'firstName': widget.firstName,
                        'lastName': widget.lastName,
                        'businessName': widget.businessName,
                        'isSingleService': widget.isSingleService,
                        'mainCategoryId': widget.mainCategoryId,
                        'mainCategoryName': widget.mainCategoryName,
                        'selectedSubCategories': widget.selectedSubCategories,
                        'selectedServiceTypes': widget.selectedServiceTypes,
                      },
                    );
                  }
                }
              },
              builder: (context, state) {
                if (state is VendorAvailabilityLoading ||
                    state is VendorAvailabilityInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                } else if (state is VendorAvailabilityError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 54,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load schedule',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<VendorAvailabilityBloc>()
                                  .add(const GetVendorAvailabilityEvent());
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is VendorAvailabilityLoaded ||
                    state is VendorAvailabilityUpdateSuccess) {
                  final availabilities = state is VendorAvailabilityLoaded
                      ? state.availabilities
                      : (state as VendorAvailabilityUpdateSuccess)
                          .availabilities;
                  final isDesktop = MediaQuery.sizeOf(context).width > 900;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 24.0 : 16.0, vertical: 24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 1200 : double.infinity,
                        ),
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildHeaderSection(isDark),
                                        _buildGridSection(
                                            availabilities, isDark, true),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    flex: 2,
                                    child: _buildSummaryPanel(
                                        availabilities, isDark),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeaderSection(isDark),
                                  _buildGridSection(
                                      availabilities, isDark, false),
                                  const SizedBox(height: 32),
                                  _buildSummaryPanel(availabilities, isDark),
                                ],
                              ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildHeaderSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, left: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Schedule',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Configure your operational working hours and weekly availability.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSection(
      List<VendorAvailability> availabilities, bool isDark, bool isDesktop) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            isDesktop ? 2 : (MediaQuery.sizeOf(context).width > 600 ? 2 : 1),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 156,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final dayAvailability =
            availabilities.firstWhere((element) => element.dayOfWeek == index,
                orElse: () => VendorAvailability(
                      dayOfWeek: index,
                      startTime: '09:00:00',
                      endTime: '17:00:00',
                      isAvailable: false,
                    ));

        return _DayAvailabilityCard(
          availability: dayAvailability,
          index: index,
          isDark: isDark,
          daysOfWeek: _daysOfWeek,
        );
      },
    );
  }

  Widget _buildSummaryPanel(
      List<VendorAvailability> availabilities, bool isDark) {
    final activeDays = availabilities.where((e) => e.isAvailable).toList();
    final activeCount = activeDays.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Summary',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$activeCount / 7 Days Active',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      activeCount == 0 ? 'Off Duty' : 'Ready to accept leads',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Operational Status',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(7, (index) {
            final dayAvail = availabilities.firstWhere(
              (e) => e.dayOfWeek == index,
              orElse: () => VendorAvailability(
                dayOfWeek: index,
                startTime: '09:00:00',
                endTime: '17:00:00',
                isAvailable: false,
              ),
            );
            final isEnabled = dayAvail.isAvailable;

            String timeText = 'Closed';
            if (isEnabled) {
              final startParts = dayAvail.startTime.split(':');
              final endParts = dayAvail.endTime.split(':');

              String formatTime(List<String> parts) {
                if (parts.length < 2) return '';
                int hour = int.tryParse(parts[0]) ?? 9;
                String min = parts[1];
                String ampm = hour >= 12 ? 'PM' : 'AM';
                int displayHour =
                    hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                return '${displayHour.toString().padLeft(2, '0')}:$min $ampm';
              }

              timeText = '${formatTime(startParts)} - ${formatTime(endParts)}';
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? AppColors.success
                          : (isDark ? Colors.white10 : Colors.black12),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _daysOfWeek[index],
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isEnabled
                            ? (isDark ? Colors.white : AppColors.textPrimary)
                            : (isDark
                                ? Colors.white30
                                : AppColors.textSecondary
                                    .withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  Text(
                    timeText,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight:
                          isEnabled ? FontWeight.w600 : FontWeight.normal,
                      color: isEnabled
                          ? (isDark ? AppColors.accentLight : AppColors.primary)
                          : (isDark
                              ? Colors.white24
                              : AppColors.textSecondary.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: isDark ? AppColors.accentLight : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Set your schedule accurately. Customers will only be able to book your services during these working hours.',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      height: 1.45,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayAvailabilityCard extends StatefulWidget {
  final VendorAvailability availability;
  final int index;
  final bool isDark;
  final List<String> daysOfWeek;

  const _DayAvailabilityCard({
    required this.availability,
    required this.index,
    required this.isDark,
    required this.daysOfWeek,
  });

  @override
  State<_DayAvailabilityCard> createState() => _DayAvailabilityCardState();
}

class _DayAvailabilityCardState extends State<_DayAvailabilityCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final availability = widget.availability;
    final index = widget.index;
    final isDark = widget.isDark;
    final isEnabled = availability.isAvailable;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: isEnabled
                ? (_isHovered
                    ? AppColors.primaryLight
                    : AppColors.primary.withValues(alpha: 0.2))
                : (isDark
                    ? (_isHovered ? Colors.white24 : AppColors.darkBorder)
                    : (_isHovered
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.border.withValues(alpha: 0.5))),
            width: _isHovered || isEnabled ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isEnabled
                  ? AppColors.primary
                      .withValues(alpha: _isHovered ? 0.08 : 0.04)
                  : Colors.black.withValues(
                      alpha: isDark
                          ? (_isHovered ? 0.2 : 0.1)
                          : (_isHovered ? 0.04 : 0.02)),
              blurRadius: _isHovered ? 16 : 8,
              offset: _isHovered ? const Offset(0, 6) : const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Day Name & CupertinoSwitch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.daysOfWeek[index],
                  style: GoogleFonts.outfit(
                    color: isEnabled
                        ? (isDark ? Colors.white : AppColors.textPrimary)
                        : (isDark
                            ? Colors.white30
                            : AppColors.textSecondary.withValues(alpha: 0.5)),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                CupertinoSwitch(
                  value: availability.isAvailable,
                  activeTrackColor: AppColors.primaryLight,
                  inactiveTrackColor: isDark
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFE2E8F0),
                  onChanged: (val) {
                    context.read<VendorAvailabilityBloc>().add(
                        UpdateLocalDayEvent(
                            dayOfWeek: index, isAvailable: val));
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Body: Time Pickers or Closed state
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isEnabled
                    ? Row(
                        key: const ValueKey('open'),
                        children: [
                          Expanded(
                            child: _TimePickerField(
                              time: availability.startTime,
                              isDark: isDark,
                              isEnabled: true,
                              isStart: true,
                              onChanged: (newTime) {
                                context.read<VendorAvailabilityBloc>().add(
                                    UpdateLocalDayEvent(
                                        dayOfWeek: index, startTime: newTime));
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TimePickerField(
                              time: availability.endTime,
                              isDark: isDark,
                              isEnabled: true,
                              isStart: false,
                              onChanged: (newTime) {
                                context.read<VendorAvailabilityBloc>().add(
                                    UpdateLocalDayEvent(
                                        dayOfWeek: index, endTime: newTime));
                              },
                            ),
                          ),
                        ],
                      )
                    : Container(
                        key: const ValueKey('closed'),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.02)
                              : Colors.black.withValues(alpha: 0.01),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.04),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_circle_outline_rounded,
                              size: 16,
                              color: isDark
                                  ? Colors.white24
                                  : AppColors.textSecondary
                                      .withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Closed',
                              style: GoogleFonts.outfit(
                                color: isDark
                                    ? Colors.white24
                                    : AppColors.textSecondary
                                        .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerField extends StatefulWidget {
  final String time;
  final bool isDark;
  final bool isEnabled;
  final bool isStart;
  final Function(String) onChanged;

  const _TimePickerField({
    required this.time,
    required this.isDark,
    this.isEnabled = true,
    required this.isStart,
    required this.onChanged,
  });

  @override
  State<_TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<_TimePickerField> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isEnabled = widget.isEnabled;
    final parts = widget.time.split(':');
    String displayTime = widget.time;
    if (parts.length >= 2) {
      int hour = int.tryParse(parts[0]) ?? 9;
      String min = parts[1];
      String ampm = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      displayTime = '${displayHour.toString().padLeft(2, '0')}:$min $ampm';
    }

    return IgnorePointer(
      ignoring: !isEnabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1.0 : 0.6,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor:
              isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: isEnabled
                ? () async {
                    final parsedTime = TimeOfDay(
                      hour: int.tryParse(parts[0]) ?? 9,
                      minute: int.tryParse(parts[1]) ?? 0,
                    );
                    final selectedTime = await showDialog<TimeOfDay>(
                      context: context,
                      builder: (context) => _CustomTimePickerDialog(
                        initialTime: parsedTime,
                        isDark: isDark,
                      ),
                    );

                    if (selectedTime != null) {
                      final hh = selectedTime.hour.toString().padLeft(2, '0');
                      final mm = selectedTime.minute.toString().padLeft(2, '0');
                      widget.onChanged('$hh:$mm:00');
                    }
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: isEnabled
                    ? (isDark
                        ? (_isHovered
                            ? AppColors.darkSurfaceVariant
                            : AppColors.darkSurface.withValues(alpha: 0.5))
                        : (_isHovered
                            ? Colors.white
                            : AppColors.surfaceVariant.withValues(alpha: 0.4)))
                    : (isDark
                        ? AppColors.darkBackground.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.02)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEnabled
                      ? (_isHovered
                          ? AppColors.primaryLight
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.border.withValues(alpha: 0.7)))
                      : (isDark
                          ? AppColors.darkBorder.withValues(alpha: 0.3)
                          : AppColors.border.withValues(alpha: 0.3)),
                  width: _isHovered && isEnabled ? 1.8 : 1.0,
                ),
                boxShadow: _isHovered && isEnabled
                    ? [
                        BoxShadow(
                          color: isDark
                              ? Colors.black26
                              : AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isEnabled) ...[
                    Icon(
                      widget.isStart
                          ? Icons.wb_sunny_outlined
                          : Icons.access_time_rounded,
                      color: widget.isStart
                          ? AppColors.accent
                          : AppColors.primaryLight,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    isEnabled ? displayTime : 'Closed',
                    style: GoogleFonts.outfit(
                      color: isEnabled
                          ? (isDark ? Colors.white : AppColors.textPrimary)
                          : (isDark
                              ? Colors.white24
                              : AppColors.textSecondary.withValues(alpha: 0.4)),
                      fontSize: 13,
                      fontWeight: isEnabled ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final bool isDark;

  const _CustomTimePickerDialog({
    required this.initialTime,
    required this.isDark,
  });

  @override
  State<_CustomTimePickerDialog> createState() =>
      _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<_CustomTimePickerDialog> {
  late int _selectedHour;
  late int _selectedMinute;
  late String _selectedPeriod;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    int hour24 = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _selectedPeriod = hour24 >= 12 ? 'PM' : 'AM';
    _selectedHour = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);

    _hourController =
        FixedExtentScrollController(initialItem: _selectedHour - 1);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black54
                  : AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Time',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color:
                            isDark ? Colors.white54 : AppColors.textSecondary,
                        size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 24, endIndent: 24),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 160,
                    child: _buildWheel(
                      controller: _hourController,
                      itemCount: 12,
                      onChanged: (index) {
                        setState(() => _selectedHour = index + 1);
                      },
                      itemBuilder: (context, index) {
                        final val = index + 1;
                        final isSelected = val == _selectedHour;
                        return Center(
                          child: Text(
                            val.toString().padLeft(2, '0'),
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : (isDark
                                      ? Colors.white38
                                      : AppColors.textSecondary
                                          .withValues(alpha: 0.5)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    ':',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 160,
                    child: _buildWheel(
                      controller: _minuteController,
                      itemCount: 60,
                      onChanged: (index) {
                        setState(() => _selectedMinute = index);
                      },
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedMinute;
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : (isDark
                                      ? Colors.white38
                                      : AppColors.textSecondary
                                          .withValues(alpha: 0.5)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPeriodButton('AM', isDark),
                      const SizedBox(height: 12),
                      _buildPeriodButton('PM', isDark),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 24, endIndent: 24),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          color:
                              isDark ? Colors.white60 : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        int finalHour = _selectedHour;
                        if (_selectedPeriod == 'PM' && finalHour < 12) {
                          finalHour += 12;
                        } else if (_selectedPeriod == 'AM' && finalHour == 12) {
                          finalHour = 0;
                        }
                        Navigator.pop(
                            context,
                            TimeOfDay(
                                hour: finalHour, minute: _selectedMinute));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Set Time',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onChanged,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      perspective: 0.003,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: itemBuilder,
        childCount: itemCount,
      ),
    );
  }

  Widget _buildPeriodButton(String label, bool isDark) {
    final isSelected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 54,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight
              : (isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight
                : (isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05)),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.textPrimary),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
