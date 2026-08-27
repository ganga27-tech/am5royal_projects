import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

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

class _SpringButtonState extends State<SpringButton> with SingleTickerProviderStateMixin {
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

class OrderDetailsScreen extends StatefulWidget {
  final OrderEntity order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == 'N/A') return 'N/A';
    try {
      String cleanTime = timeStr;
      if (cleanTime.contains('.')) {
        cleanTime = cleanTime.split('.').first;
      }
      final parts = cleanTime.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          final displayMinute = minute.toString().padLeft(2, '0');
          return '$displayHour:$displayMinute $period';
        }
      }
      return cleanTime;
    } catch (_) {
      return timeStr;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'N/A') return 'N/A';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final monthInt = int.tryParse(parts[1]);
        final day = parts[2];
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        if (monthInt != null && monthInt >= 1 && monthInt <= 12) {
          return '$day ${months[monthInt - 1]}, $year';
        }
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
      case 'PENDING':
        return AppColors.statusPending;
      case 'ACCEPTED':
        return AppColors.statusConfirmed;
      case 'IN_PROGRESS':
        return AppColors.statusInProgress;
      case 'COMPLETED':
        return AppColors.statusCompleted;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBgColor(String status, bool isDark) {
    final baseColor = _getStatusColor(status);
    return baseColor.withValues(alpha: isDark ? 0.15 : 0.08);
  }

  String _getFriendlyStatusText(String status) {
    if (status.toLowerCase() == 'new') return 'New';
    if (status.toLowerCase() == 'accepted') return 'Accepted';
    if (status.toLowerCase() == 'pending') return 'Pending';
    if (status.toLowerCase() == 'in_progress') return 'Ongoing';
    if (status.toLowerCase() == 'completed') return 'Completed';
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine the active action based on status
    final isUpcoming = ['new', 'ACCEPTED', 'PENDING'].contains(widget.order.status);
    final isOngoing = widget.order.status == 'IN_PROGRESS';
    final isCompleted = widget.order.status == 'COMPLETED';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background watercolor mask matching home screen
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
          SafeArea(
            child: BlocConsumer<OrdersBloc, OrdersState>(
              listener: (context, state) {
                if (state is OrderActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.pop(context); // Go back after success
                } else if (state is OrderActionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildOrderInfoCard(isDark),
                      const SizedBox(height: 20),
                      _buildCustomerInfoCard(isDark),
                      const SizedBox(height: 30),
                      
                      if (isUpcoming) ...[
                        _buildOtpSection(
                          title: 'Enter Start OTP to begin work',
                          hintText: 'Start OTP',
                          isDark: isDark,
                          state: state,
                          buttonText: 'Start Work',
                          buttonColor: AppColors.primary,
                          onPressed: () {
                            if (_otpController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter OTP')),
                              );
                              return;
                            }
                            context.read<OrdersBloc>().add(
                              StartServiceEvent(widget.order.bookingReference, _otpController.text),
                            );
                          },
                        ),
                      ],
                      
                      if (isOngoing) ...[
                        _buildOtpSection(
                          title: 'Enter End OTP to finish work',
                          hintText: 'End OTP',
                          isDark: isDark,
                          state: state,
                          buttonText: 'Finish Work',
                          buttonColor: AppColors.success,
                          onPressed: () {
                            if (_otpController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter OTP')),
                              );
                              return;
                            }
                            context.read<OrdersBloc>().add(
                              CompleteServiceEvent(widget.order.bookingReference, _otpController.text),
                            );
                          },
                        ),
                      ],

                      if (isCompleted) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.statusCompleted.withValues(alpha: 0.15)
                                : AppColors.statusCompletedBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.statusCompleted.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.statusCompleted,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Service Completed Successfully',
                                style: GoogleFonts.outfit(
                                  color: AppColors.statusCompleted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      ]
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDark ? AppColors.darkBorder.withValues(alpha: 0.4) : AppColors.border.withValues(alpha: 0.4),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBentoRow(IconData icon, String label, Widget valueWidget, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                valueWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(bool isDark) {
    return _buildBentoCard(
      title: 'Order Information',
      isDark: isDark,
      children: [
        if (widget.order.serviceName != null && widget.order.serviceName!.isNotEmpty) ...[
          _buildBentoRow(
            Icons.miscellaneous_services_rounded,
            'Service Booked',
            Text(
              widget.order.serviceName!,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            isDark,
          ),
        ],
        _buildBentoRow(
          Icons.tag_rounded,
          'Reference ID',
          Text(
            widget.order.bookingReference,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          isDark,
        ),
        _buildBentoRow(
          Icons.info_outline_rounded,
          'Status',
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusBadge(widget.order.status, isDark),
            ],
          ),
          isDark,
        ),
        _buildBentoRow(
          Icons.calendar_today_rounded,
          'Date',
          Text(
            _formatDate(widget.order.bookingDate),
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          isDark,
        ),
        _buildBentoRow(
          Icons.access_time_rounded,
          'Time',
          Text(
            _formatTime(widget.order.bookingTime),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          isDark,
        ),
        _buildBentoRow(
          Icons.currency_rupee_rounded,
          'Total Amount',
          Text(
            '₹${widget.order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          isDark,
        ),
      ],
    );
  }

  Widget _buildCustomerInfoCard(bool isDark) {
    final customerName = widget.order.customerName;
    final customerPhone = widget.order.customerPhone;
    final serviceAddress = widget.order.serviceAddress;
    
    return _buildBentoCard(
      title: 'Customer Information',
      isDark: isDark,
      children: [
        _buildBentoRow(
          Icons.person_rounded,
          'Name',
          Text(
            (customerName == null || customerName.isEmpty || customerName == 'N/A')
                ? 'Client Account'
                : customerName,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          isDark,
        ),
        _buildBentoRow(
          Icons.phone_rounded,
          'Phone',
          Text(
            (customerPhone == null || customerPhone.isEmpty || customerPhone == 'N/A')
                ? 'Not Provided'
                : customerPhone,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          isDark,
        ),
        _buildBentoRow(
          Icons.location_on_rounded,
          'Service Address',
          Text(
            (serviceAddress == null || serviceAddress.isEmpty || serviceAddress == 'N/A')
                ? 'Not Provided'
                : serviceAddress,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    final text = _getFriendlyStatusText(status);
    final color = _getStatusColor(status);
    final bgColor = _getStatusBgColor(status, isDark);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOtpSection({
    required String title,
    required String hintText,
    required bool isDark,
    required OrdersState state,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_clock_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
            maxLength: 6,
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••••',
              hintStyle: GoogleFonts.jetBrainsMono(
                color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.3) : AppColors.textHint.withValues(alpha: 0.5),
                letterSpacing: 8,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0F5FA),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SpringButton(
            onTap: state is OrderActionLoading ? () {} : onPressed,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: state is OrderActionLoading ? buttonColor.withValues(alpha: 0.6) : buttonColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: buttonColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: state is OrderActionLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        buttonText,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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


