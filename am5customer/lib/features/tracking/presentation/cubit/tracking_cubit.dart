import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

enum TrackingStatus { initial, loading, ready, error }

class TrackingViewState extends Equatable {
  const TrackingViewState({
    this.status = TrackingStatus.initial,
    this.snapshot,
    this.pings = const [],
    this.message,
  });

  final TrackingStatus status;
  final TrackingSnapshot? snapshot;
  final List<LocationPing> pings;
  final String? message;

  TrackingViewState copyWith({
    TrackingStatus? status,
    TrackingSnapshot? snapshot,
    List<LocationPing>? pings,
    String? message,
  }) {
    return TrackingViewState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      pings: pings ?? this.pings,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, snapshot, pings, message];
}

class TrackingCubit extends Cubit<TrackingViewState> {
  TrackingCubit(this._api, this.bookingId) : super(const TrackingViewState());

  final TrackingApi _api;
  final String bookingId;
  Timer? _poll;

  Future<void> load() async {
    emit(state.copyWith(status: TrackingStatus.loading, message: null));
    try {
      final snap = await _api.getTracking(bookingId);
      List<LocationPing> pings = const [];
      try {
        pings = await _api.getPings(bookingId, limit: 40);
      } catch (_) {}
      emit(TrackingViewState(status: TrackingStatus.ready, snapshot: snap, pings: pings));
      _startPolling(snap.isLive);
    } on Failure catch (f) {
      emit(state.copyWith(status: TrackingStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: TrackingStatus.error, message: 'Failed to load tracking'));
    }
  }

  void _startPolling(bool live) {
    _poll?.cancel();
    if (!live) return;
    _poll = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final snap = await _api.getTracking(bookingId);
        emit(state.copyWith(status: TrackingStatus.ready, snapshot: snap));
        if (!snap.isLive) _poll?.cancel();
      } catch (_) {}
    });
  }

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }
}
