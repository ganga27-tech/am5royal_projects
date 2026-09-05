import 'package:am5_core/am5_core.dart';
import 'package:equatable/equatable.dart';

enum AiFlowPhase {
  idle,
  needService,
  needDate,
  needTime,
  needVendor,
  needAddress,
  awaitingConfirmation,
  booking,
  done,
}

enum AiTimeWindow { morning, afternoon, evening, night }

class AiVendorOption extends Equatable {
  const AiVendorOption({
    required this.professional,
    required this.price,
    required this.slots,
  });

  final Professional professional;
  final double price;
  final List<BookingSlot> slots;

  @override
  List<Object?> get props => [professional.id, price, slots.length];
}

class AiBookingContext extends Equatable {
  const AiBookingContext({
    this.phase = AiFlowPhase.idle,
    this.searchQuery,
    this.service,
    this.serviceCandidates = const [],
    this.date,
    this.timeWindow,
    this.selectedSlot,
    this.vendorOptions = const [],
    this.selectedVendor,
    this.selectedPrice,
    this.addressId,
    this.addressLabel,
    this.sortCheapest = false,
    this.pendingConfirmation = false,
    this.idempotencyKey,
  });

  final AiFlowPhase phase;
  final String? searchQuery;
  final CatalogServiceItem? service;
  final List<CatalogServiceItem> serviceCandidates;
  final DateTime? date;
  final AiTimeWindow? timeWindow;
  final BookingSlot? selectedSlot;
  final List<AiVendorOption> vendorOptions;
  final Professional? selectedVendor;
  final double? selectedPrice;
  final String? addressId;
  final String? addressLabel;
  final bool sortCheapest;
  final bool pendingConfirmation;
  final String? idempotencyKey;

  bool get hasService => service != null;
  bool get hasDate => date != null;
  bool get hasTime => selectedSlot != null || timeWindow != null;
  bool get hasVendor => selectedVendor != null;
  bool get isReadyToConfirm =>
      hasService && hasDate && selectedSlot != null && hasVendor && addressId != null;

  AiBookingContext copyWith({
    AiFlowPhase? phase,
    String? searchQuery,
    CatalogServiceItem? service,
    List<CatalogServiceItem>? serviceCandidates,
    DateTime? date,
    AiTimeWindow? timeWindow,
    BookingSlot? selectedSlot,
    List<AiVendorOption>? vendorOptions,
    Professional? selectedVendor,
    double? selectedPrice,
    String? addressId,
    String? addressLabel,
    bool? sortCheapest,
    bool? pendingConfirmation,
    String? idempotencyKey,
    bool clearService = false,
    bool clearDate = false,
    bool clearSlot = false,
    bool clearVendor = false,
    bool clearAddress = false,
  }) {
    return AiBookingContext(
      phase: phase ?? this.phase,
      searchQuery: searchQuery ?? this.searchQuery,
      service: clearService ? null : (service ?? this.service),
      serviceCandidates: serviceCandidates ?? this.serviceCandidates,
      date: clearDate ? null : (date ?? this.date),
      timeWindow: timeWindow ?? this.timeWindow,
      selectedSlot: clearSlot ? null : (selectedSlot ?? this.selectedSlot),
      vendorOptions: vendorOptions ?? this.vendorOptions,
      selectedVendor: clearVendor ? null : (selectedVendor ?? this.selectedVendor),
      selectedPrice: selectedPrice ?? this.selectedPrice,
      addressId: clearAddress ? null : (addressId ?? this.addressId),
      addressLabel: clearAddress ? null : (addressLabel ?? this.addressLabel),
      sortCheapest: sortCheapest ?? this.sortCheapest,
      pendingConfirmation: pendingConfirmation ?? this.pendingConfirmation,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }

  AiBookingContext resetBooking() => const AiBookingContext();

  @override
  List<Object?> get props => [
        phase,
        service?.id,
        date,
        timeWindow,
        selectedSlot?.start,
        selectedVendor?.id,
        addressId,
        pendingConfirmation,
      ];
}
