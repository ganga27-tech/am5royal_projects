import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5customer/features/comms/presentation/cubit/chat_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockCommsApi extends Mock implements CommsApi {}

void main() {
  late _MockCommsApi api;

  setUp(() => api = _MockCommsApi());

  blocTest<ChatCubit, ChatViewState>(
    'opens thread and loads messages',
    build: () {
      when(() => api.openBookingChat('b1')).thenAnswer(
        (_) async => const ChatThread(
          id: 't1',
          bookingId: 'b1',
          status: 'open',
          customerUserId: 'c1',
          professionalUserId: 'p1',
          serviceName: 'Clean',
        ),
      );
      when(() => api.listMessages('t1')).thenAnswer(
        (_) async => [
          const ChatMessage(
            id: 'm1',
            threadId: 't1',
            bookingId: 'b1',
            senderUserId: 'p1',
            messageType: 'text',
            body: 'Hello',
            createdAt: '2026-08-07T10:00:00Z',
          ),
        ],
      );
      return ChatCubit(api, bookingId: 'b1');
    },
    act: (c) => c.load(),
    expect: () => [
      isA<ChatViewState>().having((s) => s.status, 'status', ChatStatus.loading),
      isA<ChatViewState>()
          .having((s) => s.status, 'status', ChatStatus.ready)
          .having((s) => s.messages.length, 'messages', 1),
    ],
  );
}
