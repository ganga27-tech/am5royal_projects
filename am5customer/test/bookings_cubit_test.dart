import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5customer/features/bookings/presentation/cubit/bookings_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockBookingsApi extends Mock implements BookingsApi {}

void main() {
  late _MockBookingsApi api;

  setUp(() => api = _MockBookingsApi());

  blocTest<BookingsCubit, BookingsViewState>(
    'loads my bookings',
    build: () {
      when(() => api.myBookings()).thenAnswer(
        (_) async => [
          Booking(
            id: 'b1',
            bookingCode: 'LV-TEST',
            customerUserId: 'c1',
            professionalId: 'p1',
            serviceId: 's1',
            addressId: 'a1',
            scheduledStart: DateTime.utc(2026, 8, 10, 10),
            scheduledEnd: DateTime.utc(2026, 8, 10, 11),
            serviceName: 'AC Service',
            durationMinutes: 60,
            priceAmount: 599,
            currency: 'INR',
            status: 'pending',
          ),
        ],
      );
      return BookingsCubit(api);
    },
    act: (c) => c.load(),
    expect: () => [
      isA<BookingsViewState>().having((s) => s.status, 'status', BookingsStatus.loading),
      isA<BookingsViewState>()
          .having((s) => s.status, 'status', BookingsStatus.ready)
          .having((s) => s.items.length, 'items', 1),
    ],
  );
}
