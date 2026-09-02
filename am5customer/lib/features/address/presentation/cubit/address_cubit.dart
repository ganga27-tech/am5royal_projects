import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

class AddressCubit extends Cubit<AddressViewState> {
  AddressCubit(this._api) : super(const AddressViewState.initial());

  final AddressApi _api;

  Future<void> load() async {
    emit(state.copyWith(status: AddressStatus.loading, clearMessage: true));
    try {
      final results = await Future.wait([
        _api.listAddresses(),
        _api.listServiceAreas(country: 'IN'),
      ]);
      emit(
        state.copyWith(
          status: AddressStatus.ready,
          addresses: results[0] as List<UserAddress>,
          serviceAreas: results[1] as List<ServiceArea>,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: AddressStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: AddressStatus.error, message: 'Failed to load addresses'));
    }
  }

  Future<void> save({
    String? id,
    required Map<String, dynamic> body,
  }) async {
    emit(state.copyWith(saving: true, clearMessage: true));
    try {
      if (id == null) {
        await _api.createAddress(body);
      } else {
        await _api.updateAddress(id, body);
      }
      await load();
      emit(state.copyWith(saving: false, message: 'saved'));
    } on Failure catch (f) {
      emit(state.copyWith(saving: false, message: f.message));
    } catch (_) {
      emit(state.copyWith(saving: false, message: 'Failed to save address'));
    }
  }

  Future<void> setDefault(String id) async {
    try {
      await _api.setDefault(id);
      await load();
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }

  Future<void> remove(String id) async {
    try {
      await _api.deleteAddress(id);
      await load();
      emit(state.copyWith(message: 'deleted'));
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }

  Future<ServiceabilityResult?> checkServiceability({
    required String city,
    required String postalCode,
  }) async {
    try {
      return await _api.checkServiceability(city: city, postalCode: postalCode);
    } catch (_) {
      return null;
    }
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));
}

enum AddressStatus { initial, loading, ready, error }

class AddressViewState extends Equatable {
  const AddressViewState({
    required this.status,
    this.addresses = const [],
    this.serviceAreas = const [],
    this.saving = false,
    this.message,
  });

  const AddressViewState.initial() : this(status: AddressStatus.initial);

  final AddressStatus status;
  final List<UserAddress> addresses;
  final List<ServiceArea> serviceAreas;
  final bool saving;
  final String? message;

  AddressViewState copyWith({
    AddressStatus? status,
    List<UserAddress>? addresses,
    List<ServiceArea>? serviceAreas,
    bool? saving,
    String? message,
    bool clearMessage = false,
  }) {
    return AddressViewState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      saving: saving ?? this.saving,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, addresses, serviceAreas, saving, message];
}
