import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:dio/dio.dart';

import '../domain/ai_booking_context.dart';
import '../domain/ai_intent_parser.dart';
import '../domain/ai_tool_result.dart';

class AiAssistantTools {
  AiAssistantTools({
    required SearchApi searchApi,
    required ProfessionalsApi professionalsApi,
    required BookingsApi bookingsApi,
    required AddressApi addressApi,
  })  : _searchApi = searchApi,
        _professionalsApi = professionalsApi,
        _bookingsApi = bookingsApi,
        _addressApi = addressApi;

  final SearchApi _searchApi;
  final ProfessionalsApi _professionalsApi;
  final BookingsApi _bookingsApi;
  final AddressApi _addressApi;

  Future<AiToolResult<List<CatalogServiceItem>>> searchServices({
    required String query,
    bool cheapest = false,
    int limit = 8,
  }) async {
    try {
      final result = await _searchApi.search(
        q: query,
        limit: limit,
        sort: cheapest ? 'price_asc' : 'relevance',
      );
      if (result.items.isEmpty) {
        return AiToolResult.fail(
          AiToolStatus.noResults,
          'I couldn\'t find matching services right now.',
        );
      }
      return AiToolResult.ok(result.items);
    } on Failure catch (f) {
      return _mapFailure(f);
    } on DioException catch (e) {
      return _mapDio(e);
    } catch (_) {
      return AiToolResult.fail(
        AiToolStatus.unknown,
        'Something went wrong while searching services. Please try again.',
      );
    }
  }

  Future<AiToolResult<List<AiVendorOption>>> findVendorOptions({
    required String serviceId,
    required DateTime day,
    String? pincode,
    String? city,
    AiTimeWindow? timeWindow,
    int? slotHour,
    bool cheapest = false,
  }) async {
    try {
      var pros = await _professionalsApi.listProfessionals(
        serviceId: serviceId,
        pincode: pincode,
        city: city,
        verified: true,
        available: true,
        sort: cheapest ? 'price' : 'rating',
      );
      if (pros.isEmpty) {
        pros = await _professionalsApi.listProfessionals(
          serviceId: serviceId,
          sort: cheapest ? 'price' : 'rating',
        );
      }
      if (pros.isEmpty) {
        return AiToolResult.fail(
          AiToolStatus.noResults,
          'I couldn\'t find available professionals for this service.',
        );
      }

      final options = <AiVendorOption>[];
      for (final pro in pros.take(6)) {
        final slots = await _bookingsApi.listSlots(
          professionalId: pro.id,
          serviceId: serviceId,
          day: day,
        );
        final filtered = AiIntentParser.filterSlotsByWindow(slots, timeWindow, hour: slotHour);
        if (filtered.isEmpty) continue;

        final price = await _bookingsApi.estimatePrice(
          professionalId: pro.id,
          serviceId: serviceId,
        );
        options.add(AiVendorOption(professional: pro, price: price, slots: filtered));
      }

      if (options.isEmpty) {
        return AiToolResult.fail(
          AiToolStatus.noResults,
          'No professionals are available for that time. Try another date or time window.',
        );
      }

      if (cheapest) {
        options.sort((a, b) => a.price.compareTo(b.price));
      }
      return AiToolResult.ok(options);
    } on Failure catch (f) {
      return _mapFailure(f);
    } on DioException catch (e) {
      return _mapDio(e);
    } catch (_) {
      return AiToolResult.fail(
        AiToolStatus.unknown,
        'I couldn\'t check availability right now. Please try again.',
      );
    }
  }

  Future<AiToolResult<UserAddress>> resolveDefaultAddress() async {
    try {
      final addresses = await _addressApi.listAddresses();
      if (addresses.isEmpty) {
        return AiToolResult.fail(
          AiToolStatus.validationError,
          'Please add a service address in your profile so I can find nearby professionals.',
        );
      }
      final addr = addresses.where((a) => a.isDefault).firstOrNull ?? addresses.first;
      return AiToolResult.ok(addr);
    } on Failure catch (f) {
      return _mapFailure(f);
    } on DioException catch (e) {
      return _mapDio(e);
    } catch (_) {
      return AiToolResult.fail(
        AiToolStatus.unknown,
        'I couldn\'t load your saved address.',
      );
    }
  }

  Future<AiToolResult<Booking>> createBooking({
    required String professionalId,
    required String serviceId,
    required String addressId,
    required BookingSlot slot,
    String? serviceName,
    String? professionalName,
    String? notes,
  }) async {
    try {
      final stillAvailable = await _bookingsApi.listSlots(
        professionalId: professionalId,
        serviceId: serviceId,
        day: slot.start,
        addressId: addressId,
      );
      final match = stillAvailable.any((s) => s.start == slot.start);
      if (!match) {
        return AiToolResult.fail(
          AiToolStatus.validationError,
          'That slot was just taken. Would you like me to show the next available options?',
        );
      }

      final booking = await _bookingsApi.createBooking(
        professionalId: professionalId,
        serviceId: serviceId,
        addressId: addressId,
        scheduledStart: slot.start,
        serviceName: serviceName,
        professionalName: professionalName,
        customerNotes: notes,
      );
      return AiToolResult.ok(booking);
    } on Failure catch (f) {
      return _mapFailure(f);
    } on DioException catch (e) {
      return _mapDio(e);
    } catch (_) {
      return AiToolResult.fail(
        AiToolStatus.unknown,
        'Your booking could not be confirmed. Please try again.',
      );
    }
  }

  Future<AiToolResult<List<Booking>>> getMyBookings() async {
    try {
      final bookings = await _bookingsApi.myBookings();
      if (bookings.isEmpty) {
        return AiToolResult.fail(AiToolStatus.noResults, 'You don\'t have any bookings yet.');
      }
      return AiToolResult.ok(bookings);
    } on Failure catch (f) {
      return _mapFailure(f);
    } on DioException catch (e) {
      return _mapDio(e);
    } catch (_) {
      return AiToolResult.fail(
        AiToolStatus.unknown,
        'I couldn\'t load your bookings right now.',
      );
    }
  }

  AiToolResult<T> _mapFailure<T>(Failure f) {
    final msg = f.message.toLowerCase();
    if (msg.contains('unauthorized') || msg.contains('token') || msg.contains('sign in')) {
      return AiToolResult.fail(AiToolStatus.authError, 'Please sign in to continue.');
    }
    return AiToolResult.fail(AiToolStatus.serverError, _friendlyMessage(f.message));
  }

  AiToolResult<T> _mapDio<T>(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return AiToolResult.fail(
        AiToolStatus.timeout,
        'The request timed out. Please try again.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return AiToolResult.fail(
        AiToolStatus.networkError,
        'You\'re currently offline. Please check your internet connection.',
      );
    }
    final code = e.response?.statusCode;
    if (code == 401 || code == 403) {
      return AiToolResult.fail(AiToolStatus.authError, 'Please sign in to continue.');
    }
    return AiToolResult.fail(
      AiToolStatus.serverError,
      'We\'re having trouble connecting to AM5 Royal right now. Please try again shortly.',
    );
  }

  String _friendlyMessage(String raw) {
    if (raw.length > 120) {
      return 'Something went wrong. Please try again.';
    }
    return raw;
  }
}
