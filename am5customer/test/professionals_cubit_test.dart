import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5customer/features/professionals/presentation/cubit/professionals_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements ProfessionalsApi {}

void main() {
  late _MockApi api;

  setUp(() => api = _MockApi());

  blocTest<ProfessionalsCubit, ProfessionalsViewState>(
    'loads professionals directory',
    build: () {
      when(
        () => api.listProfessionals(
          q: null,
          city: null,
          serviceId: null,
          verified: false,
          sort: 'rating',
        ),
      ).thenAnswer(
        (_) async => [
          const Professional(
            id: 'p1',
            userId: 'u1',
            displayName: 'Asha',
            country: 'IN',
            yearsExperience: 5,
            isVerified: true,
            isActive: true,
            isAvailable: true,
            ratingAvg: 4.8,
            ratingCount: 12,
            jobsCompleted: 100,
          ),
        ],
      );
      return ProfessionalsCubit(api);
    },
    act: (c) => c.load(),
    expect: () => [
      isA<ProfessionalsViewState>().having((s) => s.status, 'status', ProfessionalsStatus.loading),
      isA<ProfessionalsViewState>()
          .having((s) => s.status, 'status', ProfessionalsStatus.ready)
          .having((s) => s.items.length, 'items', 1),
    ],
  );
}
