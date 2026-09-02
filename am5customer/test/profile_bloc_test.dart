import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5customer/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileApi extends Mock implements ProfileApi {}

void main() {
  late _MockProfileApi api;
  final profile = UserProfile(
    userId: '1',
    fullName: 'Asha',
    displayName: 'Asha V',
    email: 'asha@livora.app',
    isEmailVerified: true,
    isPhoneVerified: false,
    preferredLocale: 'en',
    roles: const ['customer'],
  );

  setUp(() => api = _MockProfileApi());

  blocTest<ProfileBloc, ProfileState>(
    'loads profile',
    build: () {
      when(() => api.getMe()).thenAnswer((_) async => profile);
      return ProfileBloc(profileApi: api);
    },
    act: (b) => b.add(const ProfileStarted()),
    expect: () => [
      isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loading),
      isA<ProfileState>()
          .having((s) => s.status, 'status', ProfileStatus.ready)
          .having((s) => s.profile?.fullName, 'name', 'Asha'),
    ],
  );
}
