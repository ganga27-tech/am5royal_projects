import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

class ProfessionalsCubit extends Cubit<ProfessionalsViewState> {
  ProfessionalsCubit(this._api) : super(const ProfessionalsViewState.initial());

  final ProfessionalsApi _api;

  Future<void> load({String? q, String? city, String? serviceId}) async {
    final nextServiceId = serviceId ?? state.serviceId;
    emit(
      state.copyWith(
        status: ProfessionalsStatus.loading,
        clearMessage: true,
        q: q,
        city: city,
        serviceId: nextServiceId,
      ),
    );
    try {
      final list = await _api.listProfessionals(
        q: q ?? state.q,
        city: city ?? state.city,
        serviceId: nextServiceId,
        verified: false,
        sort: state.sort,
      );
      emit(state.copyWith(status: ProfessionalsStatus.ready, items: list));
    } on Failure catch (f) {
      emit(state.copyWith(status: ProfessionalsStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: ProfessionalsStatus.error, message: 'Failed to load professionals'));
    }
  }

  Future<void> setSort(String sort) async {
    emit(state.copyWith(sort: sort));
    await load(serviceId: state.serviceId);
  }
}

enum ProfessionalsStatus { initial, loading, ready, error }

class ProfessionalsViewState extends Equatable {
  const ProfessionalsViewState({
    required this.status,
    this.items = const [],
    this.q,
    this.city,
    this.serviceId,
    this.sort = 'rating',
    this.message,
  });

  const ProfessionalsViewState.initial() : this(status: ProfessionalsStatus.initial);

  final ProfessionalsStatus status;
  final List<Professional> items;
  final String? q;
  final String? city;
  final String? serviceId;
  final String sort;
  final String? message;

  ProfessionalsViewState copyWith({
    ProfessionalsStatus? status,
    List<Professional>? items,
    String? q,
    String? city,
    String? serviceId,
    String? sort,
    String? message,
    bool clearMessage = false,
  }) {
    return ProfessionalsViewState(
      status: status ?? this.status,
      items: items ?? this.items,
      q: q ?? this.q,
      city: city ?? this.city,
      serviceId: serviceId ?? this.serviceId,
      sort: sort ?? this.sort,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, items, q, city, serviceId, sort, message];
}

class ProfessionalDetailCubit extends Cubit<ProfessionalDetailState> {
  ProfessionalDetailCubit(
    this._api,
    this.professionalId, {
    this.serviceId,
  }) : super(const ProfessionalDetailState.initial());

  final ProfessionalsApi _api;
  final String professionalId;
  final String? serviceId;

  Future<void> load() async {
    emit(state.copyWith(status: ProfessionalDetailStatus.loading, clearMessage: true));
    try {
      final results = await Future.wait([
        _api.getProfessional(professionalId, serviceId: serviceId),
        _api.listReviews(professionalId),
      ]);
      emit(
        state.copyWith(
          status: ProfessionalDetailStatus.ready,
          professional: results[0] as Professional,
          reviews: results[1] as List<ProfessionalReview>,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: ProfessionalDetailStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: ProfessionalDetailStatus.error, message: 'Failed to load profile'));
    }
  }

  Future<void> submitReview({required int rating, String? title, String? body}) async {
    emit(state.copyWith(submitting: true, clearMessage: true));
    try {
      await _api.createReview(professionalId, rating: rating, title: title, body: body);
      await load();
      emit(state.copyWith(submitting: false, message: 'review_saved'));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, message: f.message));
    } catch (_) {
      emit(state.copyWith(submitting: false, message: 'Failed to submit review'));
    }
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));
}

enum ProfessionalDetailStatus { initial, loading, ready, error }

class ProfessionalDetailState extends Equatable {
  const ProfessionalDetailState({
    required this.status,
    this.professional,
    this.reviews = const [],
    this.submitting = false,
    this.message,
  });

  const ProfessionalDetailState.initial() : this(status: ProfessionalDetailStatus.initial);

  final ProfessionalDetailStatus status;
  final Professional? professional;
  final List<ProfessionalReview> reviews;
  final bool submitting;
  final String? message;

  ProfessionalDetailState copyWith({
    ProfessionalDetailStatus? status,
    Professional? professional,
    List<ProfessionalReview>? reviews,
    bool? submitting,
    String? message,
    bool clearMessage = false,
  }) {
    return ProfessionalDetailState(
      status: status ?? this.status,
      professional: professional ?? this.professional,
      reviews: reviews ?? this.reviews,
      submitting: submitting ?? this.submitting,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, professional, reviews, submitting, message];
}
