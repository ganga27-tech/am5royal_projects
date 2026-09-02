import 'package:equatable/equatable.dart';

class ChatThread extends Equatable {
  const ChatThread({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.customerUserId,
    required this.professionalUserId,
    this.bookingCode,
    this.serviceName,
    this.lastMessageAt,
    this.lastMessagePreview,
  });

  final String id;
  final String bookingId;
  final String? bookingCode;
  final String? serviceName;
  final String status;
  final String customerUserId;
  final String professionalUserId;
  final String? lastMessageAt;
  final String? lastMessagePreview;

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      bookingCode: json['booking_code'] as String?,
      serviceName: json['service_name'] as String?,
      status: json['status'] as String? ?? 'open',
      customerUserId: json['customer_user_id'] as String,
      professionalUserId: json['professional_user_id'] as String,
      lastMessageAt: json['last_message_at']?.toString(),
      lastMessagePreview: json['last_message_preview'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, lastMessageAt, lastMessagePreview];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.bookingId,
    required this.senderUserId,
    required this.messageType,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String threadId;
  final String bookingId;
  final String senderUserId;
  final String messageType;
  final String body;
  final String createdAt;
  final String? readAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      bookingId: json['booking_id'] as String,
      senderUserId: json['sender_user_id'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      body: json['body'] as String? ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      readAt: json['read_at']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, body, createdAt];
}

class VoiceCall extends Equatable {
  const VoiceCall({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.roomId,
    required this.provider,
    required this.initiatorUserId,
    required this.calleeUserId,
    this.providerToken,
    this.startedAt,
    this.endedAt,
    this.endReason,
  });

  final String id;
  final String bookingId;
  final String status;
  final String roomId;
  final String provider;
  final String? providerToken;
  final String initiatorUserId;
  final String calleeUserId;
  final String? startedAt;
  final String? endedAt;
  final String? endReason;

  factory VoiceCall.fromJson(Map<String, dynamic> json) {
    return VoiceCall(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      status: json['status'] as String? ?? 'ringing',
      roomId: json['room_id'] as String? ?? '',
      provider: json['provider'] as String? ?? 'mock',
      providerToken: json['provider_token'] as String?,
      initiatorUserId: json['initiator_user_id'] as String,
      calleeUserId: json['callee_user_id'] as String,
      startedAt: json['started_at']?.toString(),
      endedAt: json['ended_at']?.toString(),
      endReason: json['end_reason'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, status];
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.pushStatus,
    required this.createdAt,
    this.bookingId,
    this.readAt,
    this.data,
  });

  final String id;
  final String notificationType;
  final String title;
  final String body;
  final String? bookingId;
  final String? readAt;
  final String pushStatus;
  final String createdAt;
  final Map<String, dynamic>? data;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      notificationType: json['notification_type'] as String? ?? 'system',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      bookingId: json['booking_id'] as String?,
      readAt: json['read_at']?.toString(),
      pushStatus: json['push_status'] as String? ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, readAt, title];
}
