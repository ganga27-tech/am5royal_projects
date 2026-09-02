import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5customer/features/payments/presentation/cubit/payments_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockPaymentsApi extends Mock implements PaymentsApi {}

void main() {
  late _MockPaymentsApi api;

  setUp(() => api = _MockPaymentsApi());

  blocTest<WalletCubit, WalletViewState>(
    'loads wallet balance',
    build: () {
      when(() => api.getWallet()).thenAnswer(
        (_) async => const WalletInfo(
          id: 'w1',
          balance: 200,
          currency: 'INR',
          status: 'active',
        ),
      );
      return WalletCubit(api);
    },
    act: (c) => c.load(),
    expect: () => [
      isA<WalletViewState>().having((s) => s.status, 'status', WalletStatus.loading),
      isA<WalletViewState>()
          .having((s) => s.status, 'status', WalletStatus.ready)
          .having((s) => s.wallet?.balance, 'balance', 200),
    ],
  );
}
