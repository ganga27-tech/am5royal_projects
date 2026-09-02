import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:am5_api/am5_api.dart';

class _MockAuthApi extends Mock implements AuthApi {}

void main() {
  late _MockAuthApi api;
  const device = DeviceInfo(deviceId: 'test-device', platform: 'test');
  final user = LivoraUser(
    id: '1',
    fullName: 'Asha',
    email: 'asha@livora.app',
    status: 'active',
    roles: const ['customer'],
    isEmailVerified: true,
    isPhoneVerified: false,
    preferredLocale: 'en',
  );

  setUp(() {
    api = _MockAuthApi();
  });

  blocTest<AuthBloc, AuthState>(
    'emits authenticated when session exists',
    build: () {
      when(() => api.me()).thenAnswer((_) async => user);
      return AuthBloc(authApi: api, device: device);
    },
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.authenticated),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits unauthenticated when me fails',
    build: () {
      when(() => api.me()).thenThrow(const Failure('no session'));
      return AuthBloc(authApi: api, device: device);
    },
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.unauthenticated),
    ],
  );
}
