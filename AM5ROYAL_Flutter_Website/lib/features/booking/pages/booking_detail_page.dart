import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../widgets/service_image.dart';
import '../models/booking_models.dart';

class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({
    super.key,
    required this.booking,
  });

  final BookingDetailData booking;

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        booking.isConfirmed ? AppColors.success : const Color(0xFFE65100);
    final Color statusBg =
        booking.isConfirmed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);

    return Scaffold(
      backgroundColor: const Color(0xFFF9EBD1),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    booking.isConfirmed
                        ? Icons.check_circle_rounded
                        : Icons.schedule_rounded,
                    color: statusColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking.displayStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Booking ID: ${booking.orderId}',
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vendor Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: ServiceImage(
                            imageUrl: booking.vendorPhotoUrl,
                            name: booking.vendorName,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.vendorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.heading,
                              ),
                            ),
                            if (booking.vendorRating != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${booking.vendorRating!.toStringAsFixed(1)} ★',
                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            if (booking.vendorPhone != null &&
                                booking.vendorPhone!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                booking.vendorPhone!,
                                style: const TextStyle(
                                  color: AppColors.royalBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _detailRow('Service', booking.serviceName),
                  _detailRow('Date', booking.date),
                  _detailRow('Time', booking.time),
                  _detailRow('Address', booking.address),
                  if (booking.customerName != null &&
                      booking.customerName!.isNotEmpty)
                    _detailRow('Customer', booking.customerName!),
                  if (booking.customerPhone != null &&
                      booking.customerPhone!.isNotEmpty)
                    _detailRow('Phone', booking.customerPhone!),
                  const Divider(height: 24),
                  _detailRow(
                    'Amount',
                    '₹${booking.amount.toStringAsFixed(0)}',
                    bold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
