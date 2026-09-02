import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

enum NotifStatus { initial, loading, ready, error }

class NotificationsViewState extends Equatable {
  const NotificationsViewState({
    this.status = NotifStatus.initial,
    this.items = const [],
    this.message,
  });

  final NotifStatus status;
  final List<AppNotification> items;
  final String? message;

  NotificationsViewState copyWith({
    NotifStatus? status,
    List<AppNotification>? items,
    String? message,
  }) {
    return NotificationsViewState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}

class NotificationsCubit extends Cubit<NotificationsViewState> {
  NotificationsCubit(this._api) : super(const NotificationsViewState());

  final CommsApi _api;

  Future<void> load() async {
    emit(state.copyWith(status: NotifStatus.loading, message: null));
    try {
      final items = await _api.listNotifications();
      emit(NotificationsViewState(status: NotifStatus.ready, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(status: NotifStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: NotifStatus.error, message: 'Failed to load'));
    }
  }

  Future<void> markRead(String id) async {
    try {
      final updated = await _api.markRead(id);
      final items = state.items.map((n) => n.id == id ? updated : n).toList();
      emit(state.copyWith(items: items));
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }

  Future<void> markAll() async {
    try {
      await _api.markAllRead();
      await load();
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }
}
