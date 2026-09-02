import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class CommsApi {
  CommsApi(this._client);

  final ApiClient _client;

  Future<List<ChatThread>> listThreads() async => const [];

  Future<ChatThread> openBookingChat(String bookingId) async {
    return ChatThread(
      id: 'booking-$bookingId',
      bookingId: bookingId,
      bookingCode: bookingId,
      serviceName: 'Booking support',
      status: 'unavailable',
      customerUserId: 'customer',
      professionalUserId: 'vendor',
      lastMessagePreview: 'Chat is coming soon. Please call support for urgent help.',
    );
  }

  Future<List<ChatMessage>> listMessages(String threadId) async {
    return [
      ChatMessage(
        id: 'system-1',
        threadId: threadId,
        bookingId: threadId.replaceFirst('booking-', ''),
        senderUserId: 'system',
        messageType: 'system',
        body: 'In-app chat is not available yet. Use Support for help with this booking.',
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    ];
  }

  Future<ChatMessage> sendMessage(String threadId, String body) async {
    throw const Failure('Chat is not available yet. Please use Support.');
  }

  Future<VoiceCall> startCall(String bookingId) async {
    throw const Failure('In-app calling is not available yet.');
  }

  Future<VoiceCall> answerCall(String callId) async {
    throw const Failure('In-app calling is not available yet.');
  }

  Future<VoiceCall> endCall(String callId, {String reason = 'hangup'}) async {
    throw const Failure('In-app calling is not available yet.');
  }

  Future<void> registerPushToken({
    required String token,
    String platform = 'android',
    String? deviceId,
  }) async {
    try {
      await _client.dio.post(
        '/devices/sync',
        data: {
          'device_id': deviceId ?? 'unknown-device',
          'fcm_token': token,
          'app_version': '1.0.0',
        },
      );
      await _client.dio.put(
        '/auth/users/fcm-token',
        data: {'fcm_token': token},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return;
      throw _client.mapDioError(e);
    }
  }

  Future<List<AppNotification>> listNotifications() async => const [];

  Future<AppNotification> markRead(String id) async {
    return AppNotification(
      id: id,
      notificationType: 'system',
      title: 'Notification',
      body: '',
      pushStatus: 'read',
      createdAt: DateTime.now().toUtc().toIso8601String(),
      readAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<void> markAllRead() async {}
}
