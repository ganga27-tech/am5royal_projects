import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5customer/features/tracking/presentation/cubit/tracking_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockTrackingApi extends Mock implements TrackingApi {}

void main() {
  late _MockTrackingApi api;

  setUp(() => api = _MockTrackingApi());

  blocTest<TrackingCubit, TrackingViewState>(
    'loads tracking snapshot',
    build: () {
      when(() => api.getTracking('b1')).thenAnswer(
        (_) async => const TrackingSnapshot(
          bookingId: 'b1',
          bookingCode: 'LV-1',
          bookingStatus: 'confirmed',
          trackingStatus: 'en_route',
          isLive: false,
          destinationLatitude: 12.97,
          destinationLongitude: 77.59,
          professionalLatitude: 12.98,
          professionalLongitude: 77.60,
          etaMinutes: 5,
          distanceKm: 1.2,
        ),
      );
      when(() => api.getPings('b1', limit: any(named: 'limit'))).thenAnswer((_) async => []);
      return TrackingCubit(api, 'b1');
    },
    act: (c) => c.load(),
    expect: () => [
      isA<TrackingViewState>().having((s) => s.status, 'status', TrackingStatus.loading),
      isA<TrackingViewState>()
          .having((s) => s.status, 'status', TrackingStatus.ready)
          .having((s) => s.snapshot?.etaMinutes, 'eta', 5),
    ],
  );
}
