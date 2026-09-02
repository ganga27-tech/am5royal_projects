import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5customer/features/address/presentation/cubit/address_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockAddressApi extends Mock implements AddressApi {}

void main() {
  late _MockAddressApi api;

  setUp(() => api = _MockAddressApi());

  blocTest<AddressCubit, AddressViewState>(
    'loads addresses and service areas',
    build: () {
      when(() => api.listAddresses()).thenAnswer(
        (_) async => [
          const UserAddress(
            id: 'a1',
            label: 'home',
            line1: '12 Road',
            city: 'Bengaluru',
            state: 'Karnataka',
            postalCode: '560025',
            country: 'IN',
            isDefault: true,
            isServiceable: true,
          ),
        ],
      );
      when(() => api.listServiceAreas(country: 'IN')).thenAnswer(
        (_) async => [
          const ServiceArea(
            id: 's1',
            name: 'Bengaluru Core',
            city: 'Bengaluru',
            state: 'Karnataka',
            country: 'IN',
            centerLatitude: 12.97,
            centerLongitude: 77.59,
            radiusKm: 30,
            isActive: true,
          ),
        ],
      );
      return AddressCubit(api);
    },
    act: (c) => c.load(),
    expect: () => [
      isA<AddressViewState>().having((s) => s.status, 'status', AddressStatus.loading),
      isA<AddressViewState>()
          .having((s) => s.status, 'status', AddressStatus.ready)
          .having((s) => s.addresses.length, 'addresses', 1)
          .having((s) => s.serviceAreas.length, 'areas', 1),
    ],
  );
}
