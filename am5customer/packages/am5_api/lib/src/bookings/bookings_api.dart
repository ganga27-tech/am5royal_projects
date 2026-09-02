import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class BookingsApi {
  BookingsApi(this._client);

  final ApiClient _client;

  Future<List<BookingSlot>> listSlots({
    required String professionalId,
    required String serviceId,
    required DateTime day,
    String? addressId,
  }) async {
    try {
      final response = await _client.dio.get(
        '/orders/availableServiceProviderSlots',
        queryParameters: {
          'serviceIds': serviceId,
          'serviceDate': _formatDate(day),
          if (addressId != null) 'addressId': addressId,
        },
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => BookingSlot.fromAm5Slot(e.toString(), day))
          .toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<Booking> createBooking({
    required String professionalId,
    required String serviceId,
    required String addressId,
    required DateTime scheduledStart,
    String? customerNotes,
  }) async {
    try {
      final subcategoryId = int.tryParse(serviceId);
      if (subcategoryId == null) {
        throw const Failure('Invalid service selected');
      }

      final unitPrice = await _resolveUnitPrice(
        vendorId: professionalId,
        subcategoryId: subcategoryId,
      );

      final response = await _client.dio.post(
        '/orders/',
        data: {
          'address_id': int.parse(addressId),
          'payment_method': 'COD',
          'scheduled_at': scheduledStart.toUtc().toIso8601String(),
          'vendor_profile_id': int.tryParse(professionalId),
          'catalog_service_id': subcategoryId,
          'items': [
            {
              'subcategory_id': subcategoryId,
              'quantity': 1,
              'unit_price': unitPrice,
            },
          ],
        },
      );

      final data = response.data as Map<String, dynamic>;
      return Booking.fromAm5Order({
        'orderId': data['orderId'],
        'status': data['status'] ?? 'PENDING',
        'service_name': 'Service',
        'serviceDate': _formatDate(scheduledStart),
        'serviceTime': _formatTime(scheduledStart),
        'finalAmount': unitPrice,
      });
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<Booking>> myBookings({String? status}) async {
    try {
      final response = await _client.dio.get('/orders/');
      final list = response.data as List<dynamic>;
      var bookings = list
          .map((e) => Booking.fromAm5Order(e as Map<String, dynamic>))
          .toList();
      if (status != null) {
        bookings = bookings.where((b) => b.status == status.toLowerCase()).toList();
      }
      return bookings;
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<Booking> cancelBooking(String id, {String? reason}) async {
    try {
      await _client.dio.put(
        '/orders/$id/cancel',
        queryParameters: {'reason': reason ?? 'Cancelled by customer'},
      );
      final bookings = await myBookings();
      return bookings.firstWhere(
        (b) => b.id == id || b.bookingCode == id,
        orElse: () => Booking.fromAm5Order({
          'orderId': id,
          'status': 'CANCELLED',
          'service_name': 'Service',
        }),
      );
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<double> _resolveUnitPrice({
    required String vendorId,
    required int subcategoryId,
  }) async {
    try {
      final response = await _client.dio.get(
        '/catalog/vendors/$vendorId/services',
        queryParameters: {'subcategory_id': subcategoryId},
      );
      final list = response.data as List<dynamic>;
      if (list.isNotEmpty) {
        final first = list.first as Map<String, dynamic>;
        final price = first['discounted_price'] ?? first['price'];
        if (price is num) return price.toDouble();
        return double.tryParse('$price') ?? 499;
      }
    } catch (_) {}

    try {
      final response = await _client.dio.get(
        '/catalog/packages',
        queryParameters: {'subcategory_id': subcategoryId, 'limit': 1},
      );
      final list = response.data as List<dynamic>;
      if (list.isNotEmpty) {
        final first = list.first as Map<String, dynamic>;
        final price = first['price'];
        if (price is num) return price.toDouble();
        return double.tryParse('$price') ?? 499;
      }
    } catch (_) {}

    return 499;
  }

  String _formatDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Partner methods kept for API compatibility — not used by customer app.
  Future<List<Booking>> partnerBookings({String? status}) async {
    throw const Failure('Partner bookings are not available in the customer app.');
  }

  Future<Booking> partnerAction(String id, String action, {String? reason}) async {
    throw const Failure('Partner actions are not available in the customer app.');
  }

  Future<List<AvailabilityRule>> getAvailability() async {
    throw const Failure('Partner availability is not available in the customer app.');
  }

  Future<List<AvailabilityRule>> putAvailability(List<AvailabilityRule> rules) async {
    throw const Failure('Partner availability is not available in the customer app.');
  }

  Future<List<TimeOffEntry>> listTimeOff() async {
    throw const Failure('Partner time-off is not available in the customer app.');
  }

  Future<TimeOffEntry> createTimeOff({
    required DateTime startsAt,
    required DateTime endsAt,
    String? reason,
  }) async {
    throw const Failure('Partner time-off is not available in the customer app.');
  }

  Future<void> deleteTimeOff(String id) async {
    throw const Failure('Partner time-off is not available in the customer app.');
  }
}
