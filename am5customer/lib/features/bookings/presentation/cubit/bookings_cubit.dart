import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

class BookingsCubit extends Cubit<BookingsViewState> {
  BookingsCubit(this._api) : super(const BookingsViewState.initial());

  final BookingsApi _api;

  Future<void> load() async {
    emit(state.copyWith(status: BookingsStatus.loading, clearMessage: true));
    try {
      final items = await _api.myBookings();
      emit(state.copyWith(status: BookingsStatus.ready, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(status: BookingsStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: BookingsStatus.error, message: 'Failed to load bookings'));
    }
  }

  Future<void> cancel(String id) async {
    try {
      await _api.cancelBooking(id, reason: 'Cancelled by customer');
      await load();
      emit(state.copyWith(message: 'cancelled'));
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));
}

enum BookingsStatus { initial, loading, ready, error }

class BookingsViewState extends Equatable {
  const BookingsViewState({
    required this.status,
    this.items = const [],
    this.message,
  });

  const BookingsViewState.initial() : this(status: BookingsStatus.initial);

  final BookingsStatus status;
  final List<Booking> items;
  final String? message;

  BookingsViewState copyWith({
    BookingsStatus? status,
    List<Booking>? items,
    String? message,
    bool clearMessage = false,
  }) {
    return BookingsViewState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}

class CreateBookingCubit extends Cubit<CreateBookingState> {
  CreateBookingCubit(
    this._bookingsApi,
    this._addressApi,
    this._professionalsApi,
    this._catalogApi,
  ) : super(const CreateBookingState.initial());

  final BookingsApi _bookingsApi;
  final AddressApi _addressApi;
  final ProfessionalsApi _professionalsApi;
  final CatalogApi _catalogApi;

  Future<void> bootstrap({
    required String professionalId,
    required String serviceId,
    required String professionalName,
    required String serviceName,
  }) async {
    final day = DateTime.now().add(const Duration(days: 1));
    emit(
      state.copyWith(
        status: CreateBookingStatus.loading,
        professionalId: professionalId,
        serviceId: serviceId,
        professionalName: professionalName,
        serviceName: serviceName,
        day: day,
        clearMessage: true,
      ),
    );
    try {
      await _loadSlotsAndAddresses(
        professionalId: professionalId,
        serviceId: serviceId,
        day: day,
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: CreateBookingStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: CreateBookingStatus.error, message: 'Failed to load booking form'));
    }
  }

  /// Service-first booking: auto-assign top-rated available professional.
  Future<void> bootstrapFromService({
    required String serviceId,
    String? serviceName,
  }) async {
    final day = DateTime.now().add(const Duration(days: 1));
    emit(
      state.copyWith(
        status: CreateBookingStatus.loading,
        serviceId: serviceId,
        serviceName: serviceName,
        day: day,
        clearMessage: true,
      ),
    );
    try {
      var pros = await _professionalsApi.listProfessionals(
        serviceId: serviceId,
        verified: true,
        available: true,
        sort: 'rating',
      );
      if (pros.isEmpty) {
        pros = await _professionalsApi.listProfessionals(
          serviceId: serviceId,
          sort: 'rating',
        );
      }
      if (pros.isEmpty) {
        emit(
          state.copyWith(
            status: CreateBookingStatus.error,
            message: 'No professionals available for this service yet.',
          ),
        );
        return;
      }
      final pro = pros.first;
      var name = serviceName?.trim() ?? '';
      if (name.isEmpty) {
        try {
          name = (await _catalogApi.getService(serviceId)).name;
        } catch (_) {
          name = 'Service';
        }
      }
      emit(
        state.copyWith(
          professionalId: pro.id,
          professionalName: pro.displayName,
          serviceName: name,
        ),
      );
      await _loadSlotsAndAddresses(
        professionalId: pro.id,
        serviceId: serviceId,
        day: day,
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: CreateBookingStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: CreateBookingStatus.error, message: 'Failed to load booking form'));
    }
  }

  Future<void> _loadSlotsAndAddresses({
    required String professionalId,
    required String serviceId,
    required DateTime day,
  }) async {
    List<UserAddress> addresses = [];
    try {
      addresses = await _addressApi.listAddresses();
    } catch (_) {
      addresses = [];
    }
    final defaultAddr =
        addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull;
    final slots = await _bookingsApi.listSlots(
      professionalId: professionalId,
      serviceId: serviceId,
      day: day,
      addressId: defaultAddr?.id,
    );
    final estimatedPrice = await _bookingsApi.estimatePrice(
      professionalId: professionalId,
      serviceId: serviceId,
    );
    emit(
      state.copyWith(
        status: CreateBookingStatus.ready,
        addresses: addresses,
        slots: slots,
        selectedAddressId: defaultAddr?.id,
        estimatedPrice: estimatedPrice,
      ),
    );
  }

  Future<void> selectDay(DateTime day) async {
    emit(state.copyWith(day: day, selectedSlot: null));
    if (state.professionalId == null || state.serviceId == null) return;
    try {
      final slots = await _bookingsApi.listSlots(
        professionalId: state.professionalId!,
        serviceId: state.serviceId!,
        day: day,
        addressId: state.selectedAddressId,
      );
      emit(state.copyWith(slots: slots));
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }

  void selectSlot(BookingSlot slot) => emit(state.copyWith(selectedSlot: slot));

  void selectAddress(String id) => emit(state.copyWith(selectedAddressId: id));

  void setGuestAddress(GuestAddressDraft draft) {
    emit(state.copyWith(guestAddress: draft, selectedAddressId: null));
  }

  Future<void> ensureAddressReady() async {
    if (state.selectedAddressId != null) return;
    final guest = state.guestAddress;
    if (guest == null || !guest.isComplete) {
      throw const Failure('Please enter a complete delivery address');
    }
    final created = await _addressApi.createAddress({
      'label': 'home',
      'line1': guest.line1,
      if (guest.line2 != null) 'line2': guest.line2,
      'city': guest.city,
      'state': guest.state,
      'postal_code': guest.pincode,
      'is_default': true,
    });
    emit(state.copyWith(
      addresses: [...state.addresses, created],
      selectedAddressId: created.id,
      guestAddress: null,
    ));
  }

  Future<void> reloadAddresses() async {
    try {
      final addresses = await _addressApi.listAddresses();
      final selected = state.selectedAddressId;
      final defaultAddr =
          addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull;
      emit(
        state.copyWith(
          addresses: addresses,
          selectedAddressId: selected != null && addresses.any((a) => a.id == selected)
              ? selected
              : defaultAddr?.id,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    } catch (_) {
      emit(state.copyWith(message: 'Failed to load addresses'));
    }
  }

  Future<void> submit({String? notes}) async {
    if (state.selectedSlot == null || state.selectedAddressId == null) {
      emit(state.copyWith(message: 'Select a slot and address'));
      return;
    }
    emit(state.copyWith(submitting: true, clearMessage: true));
    try {
      final booking = await _bookingsApi.createBooking(
        professionalId: state.professionalId!,
        serviceId: state.serviceId!,
        addressId: state.selectedAddressId!,
        scheduledStart: state.selectedSlot!.start,
        customerNotes: notes,
        serviceName: state.serviceName,
        professionalName: state.professionalName,
      );
      emit(state.copyWith(submitting: false, created: booking, message: 'booked'));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, message: f.message));
    } catch (_) {
      emit(state.copyWith(submitting: false, message: 'Booking failed'));
    }
  }
}

enum CreateBookingStatus { initial, loading, ready, error }

class GuestAddressDraft extends Equatable {
  const GuestAddressDraft({
    this.line1 = '',
    this.line2,
    this.city = '',
    this.state = '',
    this.pincode = '',
  });

  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;

  bool get isComplete =>
      line1.trim().length >= 3 &&
      city.trim().isNotEmpty &&
      state.trim().isNotEmpty &&
      pincode.trim().length >= 6;

  String get summaryLine => '$line1, $city $pincode';

  GuestAddressDraft copyWith({
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? pincode,
  }) {
    return GuestAddressDraft(
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
    );
  }

  @override
  List<Object?> get props => [line1, line2, city, state, pincode];
}

class CreateBookingState extends Equatable {
  const CreateBookingState({
    required this.status,
    this.professionalId,
    this.serviceId,
    this.professionalName,
    this.serviceName,
    this.day,
    this.slots = const [],
    this.addresses = const [],
    this.selectedSlot,
    this.selectedAddressId,
    this.submitting = false,
    this.created,
    this.message,
    this.estimatedPrice,
    this.guestAddress,
  });

  const CreateBookingState.initial() : this(status: CreateBookingStatus.initial);

  final CreateBookingStatus status;
  final String? professionalId;
  final String? serviceId;
  final String? professionalName;
  final String? serviceName;
  final DateTime? day;
  final List<BookingSlot> slots;
  final List<UserAddress> addresses;
  final BookingSlot? selectedSlot;
  final String? selectedAddressId;
  final bool submitting;
  final Booking? created;
  final String? message;
  final double? estimatedPrice;
  final GuestAddressDraft? guestAddress;

  CreateBookingState copyWith({
    CreateBookingStatus? status,
    String? professionalId,
    String? serviceId,
    String? professionalName,
    String? serviceName,
    DateTime? day,
    List<BookingSlot>? slots,
    List<UserAddress>? addresses,
    BookingSlot? selectedSlot,
    String? selectedAddressId,
    bool? submitting,
    Booking? created,
    String? message,
    double? estimatedPrice,
    GuestAddressDraft? guestAddress,
    bool clearMessage = false,
  }) {
    return CreateBookingState(
      status: status ?? this.status,
      professionalId: professionalId ?? this.professionalId,
      serviceId: serviceId ?? this.serviceId,
      professionalName: professionalName ?? this.professionalName,
      serviceName: serviceName ?? this.serviceName,
      day: day ?? this.day,
      slots: slots ?? this.slots,
      addresses: addresses ?? this.addresses,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      submitting: submitting ?? this.submitting,
      created: created ?? this.created,
      message: clearMessage ? null : (message ?? this.message),
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      guestAddress: guestAddress ?? this.guestAddress,
    );
  }

  @override
  List<Object?> get props => [
        status,
        professionalId,
        serviceId,
        day,
        slots,
        addresses,
        selectedSlot,
        selectedAddressId,
        submitting,
        created,
        message,
        estimatedPrice,
        guestAddress,
      ];
}
