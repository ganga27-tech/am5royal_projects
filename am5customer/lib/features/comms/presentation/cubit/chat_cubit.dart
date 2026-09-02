import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

enum ChatStatus { initial, loading, ready, error }

class ChatViewState extends Equatable {
  const ChatViewState({
    this.status = ChatStatus.initial,
    this.thread,
    this.messages = const [],
    this.message,
    this.sending = false,
    this.activeCall,
  });

  final ChatStatus status;
  final ChatThread? thread;
  final List<ChatMessage> messages;
  final String? message;
  final bool sending;
  final VoiceCall? activeCall;

  ChatViewState copyWith({
    ChatStatus? status,
    ChatThread? thread,
    List<ChatMessage>? messages,
    String? message,
    bool? sending,
    VoiceCall? activeCall,
    bool clearCall = false,
  }) {
    return ChatViewState(
      status: status ?? this.status,
      thread: thread ?? this.thread,
      messages: messages ?? this.messages,
      message: message,
      sending: sending ?? this.sending,
      activeCall: clearCall ? null : (activeCall ?? this.activeCall),
    );
  }

  @override
  List<Object?> get props => [status, thread, messages, message, sending, activeCall];
}

class ChatCubit extends Cubit<ChatViewState> {
  ChatCubit(this._api, {required this.bookingId, this.currentUserId})
      : super(const ChatViewState());

  final CommsApi _api;
  final String bookingId;
  final String? currentUserId;

  Future<void> load() async {
    emit(state.copyWith(status: ChatStatus.loading, message: null));
    try {
      final thread = await _api.openBookingChat(bookingId);
      final messages = await _api.listMessages(thread.id);
      emit(ChatViewState(status: ChatStatus.ready, thread: thread, messages: messages));
    } on Failure catch (f) {
      emit(state.copyWith(status: ChatStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: ChatStatus.error, message: 'Failed to load chat'));
    }
  }

  Future<void> send(String body) async {
    final thread = state.thread;
    if (thread == null || body.trim().isEmpty) return;
    emit(state.copyWith(sending: true, message: null));
    try {
      final msg = await _api.sendMessage(thread.id, body.trim());
      emit(state.copyWith(
        sending: false,
        messages: [...state.messages, msg],
        status: ChatStatus.ready,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(sending: false, message: f.message));
    } catch (_) {
      emit(state.copyWith(sending: false, message: 'Send failed'));
    }
  }

  Future<void> startCall() async {
    try {
      final call = await _api.startCall(bookingId);
      emit(state.copyWith(activeCall: call, message: 'call_started'));
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }

  Future<void> answerCall() async {
    final call = state.activeCall;
    if (call == null) return;
    try {
      final updated = await _api.answerCall(call.id);
      emit(state.copyWith(activeCall: updated));
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }

  Future<void> endCall() async {
    final call = state.activeCall;
    if (call == null) return;
    try {
      await _api.endCall(call.id);
      emit(state.copyWith(clearCall: true, message: 'call_ended'));
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }

  void clearMessage() => emit(state.copyWith(message: null));
}
