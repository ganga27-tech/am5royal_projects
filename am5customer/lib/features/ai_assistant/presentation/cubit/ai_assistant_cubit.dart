import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

import '../../data/ai_assistant_tools.dart';
import '../../domain/ai_booking_context.dart';
import '../../domain/ai_intent_parser.dart';
import '../../domain/ai_tool_result.dart';

enum AiMessageRole { user, assistant }

enum AiMessageKind {
  text,
  serviceOptions,
  vendorOptions,
  confirmation,
  bookingSuccess,
  bookingFailure,
  bookingsList,
}

class AiMessage extends Equatable {
  const AiMessage({
    required this.id,
    required this.role,
    required this.text,
    this.kind = AiMessageKind.text,
    this.services = const [],
    this.vendorOptions = const [],
    this.booking,
    this.bookings = const [],
    this.showConfirmActions = false,
    this.showRetry = false,
  });

  final String id;
  final AiMessageRole role;
  final String text;
  final AiMessageKind kind;
  final List<CatalogServiceItem> services;
  final List<AiVendorOption> vendorOptions;
  final Booking? booking;
  final List<Booking> bookings;
  final bool showConfirmActions;
  final bool showRetry;

  @override
  List<Object?> get props => [id, role, text, kind, services, vendorOptions, booking];
}

class AiAssistantState extends Equatable {
  const AiAssistantState({
    this.messages = const [],
    this.loading = false,
    this.loadingLabel = 'Thinking…',
    this.context = const AiBookingContext(),
    this.bookingInProgress = false,
    this.needsAuthForBooking = false,
    this.lastBookingAttemptKey,
  });

  final List<AiMessage> messages;
  final bool loading;
  final String loadingLabel;
  final AiBookingContext context;
  final bool bookingInProgress;
  final bool needsAuthForBooking;
  final String? lastBookingAttemptKey;

  AiAssistantState copyWith({
    List<AiMessage>? messages,
    bool? loading,
    String? loadingLabel,
    AiBookingContext? context,
    bool? bookingInProgress,
    bool? needsAuthForBooking,
    String? lastBookingAttemptKey,
    bool clearAuthFlag = false,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      loadingLabel: loadingLabel ?? this.loadingLabel,
      context: context ?? this.context,
      bookingInProgress: bookingInProgress ?? this.bookingInProgress,
      needsAuthForBooking: clearAuthFlag ? false : (needsAuthForBooking ?? this.needsAuthForBooking),
      lastBookingAttemptKey: lastBookingAttemptKey ?? this.lastBookingAttemptKey,
    );
  }

  @override
  List<Object?> get props => [messages, loading, loadingLabel, context, bookingInProgress];
}

class AiAssistantCubit extends Cubit<AiAssistantState> {
  AiAssistantCubit({
    required AiAssistantTools tools,
    required bool Function() isAuthenticated,
  })  : _tools = tools,
        _isAuthenticated = isAuthenticated,
        super(const AiAssistantState()) {
    _welcome();
  }

  final AiAssistantTools _tools;
  final bool Function() _isAuthenticated;

  void _welcome() {
    emit(
      state.copyWith(
        messages: [
          AiMessage(
            id: 'welcome',
            role: AiMessageRole.assistant,
            text:
                'Hi! I\'m your AM5 Royal assistant. Tell me what you need — I can find services, recommend professionals, and help you book.',
          ),
        ],
      ),
    );
  }

  Future<void> sendSuggested(String prompt) => send(prompt);

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || state.loading || state.bookingInProgress) return;

    final userMsg = AiMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}-u',
      role: AiMessageRole.user,
      text: text,
    );
    emit(state.copyWith(messages: [...state.messages, userMsg], loading: true));

    try {
      final beforeCount = state.messages.length;
      final parsed = AiIntentParser.parse(text, context: state.context);

      if (parsed.intent == AiUserIntent.confirm &&
          state.context.pendingConfirmation &&
          state.context.isReadyToConfirm) {
        await confirmBooking();
        emit(state.copyWith(loading: false));
        return;
      }

      final reply = await _handleMessage(text, parsed);
      if (state.messages.length > beforeCount) {
        emit(state.copyWith(loading: false));
      } else {
        emit(state.copyWith(messages: [...state.messages, reply], loading: false));
      }
    } catch (_) {
      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            AiMessage(
              id: '${DateTime.now().millisecondsSinceEpoch}-err',
              role: AiMessageRole.assistant,
              text: 'Something went wrong. Please try again.',
              showRetry: true,
            ),
          ],
          loading: false,
        ),
      );
    }
  }

  Future<void> selectService(int index) async {
    final candidates = state.context.serviceCandidates;
    if (index < 0 || index >= candidates.length || state.loading) return;
    emit(state.copyWith(loading: true, loadingLabel: 'Loading service…'));
    final reply = await _applyServiceAndReturn(candidates[index]);
    emit(state.copyWith(messages: [...state.messages, reply], loading: false));
  }

  Future<void> selectVendor(int index) async {
    final options = state.context.vendorOptions;
    if (index < 0 || index >= options.length || state.loading) return;
    emit(state.copyWith(loading: true, loadingLabel: 'Selecting professional…'));
    final reply = await _applyVendorAndReturn(options[index]);
    emit(state.copyWith(messages: [...state.messages, reply], loading: false));
  }

  Future<void> confirmBooking() async {
    if (!state.context.isReadyToConfirm || state.bookingInProgress) return;

    if (!_isAuthenticated()) {
      emit(state.copyWith(needsAuthForBooking: true));
      return;
    }

    final key = state.context.idempotencyKey ??
        '${state.context.service!.id}-${state.context.selectedVendor!.id}-${state.context.selectedSlot!.start.toIso8601String()}';

    if (state.lastBookingAttemptKey == key && state.bookingInProgress) return;

    emit(state.copyWith(
      bookingInProgress: true,
      lastBookingAttemptKey: key,
      loading: true,
      loadingLabel: 'Confirming your booking…',
    ));

    final ctx = state.context;
    final result = await _tools.createBooking(
      professionalId: ctx.selectedVendor!.id,
      serviceId: ctx.service!.id,
      addressId: ctx.addressId!,
      slot: ctx.selectedSlot!,
      serviceName: ctx.service!.name,
      professionalName: ctx.selectedVendor!.displayName,
    );

    if (result.isSuccess && result.data != null) {
      emit(
        state.copyWith(
          loading: false,
          bookingInProgress: false,
          context: state.context.resetBooking(),
          messages: [
            ...state.messages,
            AiMessage(
              id: '${DateTime.now().millisecondsSinceEpoch}-ok',
              role: AiMessageRole.assistant,
              kind: AiMessageKind.bookingSuccess,
              text: 'Booking confirmed!',
              booking: result.data,
            ),
          ],
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loading: false,
        bookingInProgress: false,
        messages: [
          ...state.messages,
          AiMessage(
            id: '${DateTime.now().millisecondsSinceEpoch}-fail',
            role: AiMessageRole.assistant,
            kind: AiMessageKind.bookingFailure,
            text: result.userMessage ?? 'Your booking could not be confirmed.',
            showRetry: true,
          ),
        ],
      ),
    );
  }

  void clearAuthFlag() => emit(state.copyWith(clearAuthFlag: true));

  void cancelBookingFlow() {
    emit(
      state.copyWith(
        context: state.context.resetBooking(),
        messages: [
          ...state.messages,
          AiMessage(
            id: '${DateTime.now().millisecondsSinceEpoch}-cancel',
            role: AiMessageRole.assistant,
            text: 'No problem — booking cancelled. What else can I help you with?',
          ),
        ],
      ),
    );
  }

  Future<AiMessage> _handleMessage(String text, ParsedUserMessage parsed) async {
    var ctx = state.context;

    switch (parsed.intent) {
      case AiUserIntent.greeting:
        return _text('Hello! What service can I help you book today?');
      case AiUserIntent.help:
        return _text('Tell me the service you need, when you want it, and I\'ll find verified professionals.');
      case AiUserIntent.reset:
      case AiUserIntent.cancel:
        emit(state.copyWith(context: ctx.resetBooking()));
        return _text('Okay, let\'s start fresh. What service do you need?');
      case AiUserIntent.confirm:
        return _text('I don\'t have a booking ready to confirm yet. What service do you need?');
      case AiUserIntent.showBookings:
        return _showBookings();
      case AiUserIntent.selectService:
        if (parsed.serviceIndex != null) {
          return await _applyServiceAndReturn(ctx.serviceCandidates[parsed.serviceIndex!]);
        }
        break;
      case AiUserIntent.selectCheapest:
      case AiUserIntent.selectFirst:
      case AiUserIntent.selectVendor:
        if (ctx.vendorOptions.isNotEmpty) {
          final idx = parsed.intent == AiUserIntent.selectCheapest
              ? 0
              : parsed.intent == AiUserIntent.selectFirst
                  ? 0
                  : (parsed.vendorIndex ?? 0);
          return await _applyVendorAndReturn(ctx.vendorOptions[idx]);
        }
        break;
      case AiUserIntent.setDate:
        if (parsed.date != null) {
          ctx = ctx.copyWith(date: parsed.date, phase: AiFlowPhase.needTime);
          emit(state.copyWith(context: ctx));
          if (ctx.hasService) return _searchVendors(ctx);
          return _text('Got it. What service do you need on ${_formatDate(parsed.date!)}?');
        }
        break;
      case AiUserIntent.setTime:
        ctx = ctx.copyWith(
          timeWindow: parsed.timeWindow ?? ctx.timeWindow,
          date: parsed.date ?? ctx.date,
        );
        emit(state.copyWith(context: ctx));
        if (ctx.hasService && ctx.date != null) return _searchVendors(ctx);
        return _text('Sure. Which service do you need?');
      case AiUserIntent.search:
        break;
      case AiUserIntent.unknown:
        break;
      case AiUserIntent.selectByIndex:
        break;
    }

    if (parsed.isCheapest) {
      ctx = ctx.copyWith(sortCheapest: true);
    }
    if (parsed.date != null) {
      ctx = ctx.copyWith(date: parsed.date);
    }
    if (parsed.timeWindow != null) {
      ctx = ctx.copyWith(timeWindow: parsed.timeWindow);
    }
    if (parsed.searchQuery != null) {
      ctx = ctx.copyWith(searchQuery: parsed.searchQuery);
    }
    emit(state.copyWith(context: ctx, loadingLabel: 'Searching services…'));

    final query = parsed.searchQuery ?? text;
    final search = await _tools.searchServices(query: query, cheapest: ctx.sortCheapest);
    if (!search.isSuccess) {
      return _text(search.userMessage ?? 'No services found.');
    }

    final services = search.data!;
    if (services.length == 1) {
      return _applyServiceAndReturn(services.first);
    }

    ctx = ctx.copyWith(
      serviceCandidates: services.take(6).toList(),
      phase: AiFlowPhase.needService,
    );
    emit(state.copyWith(context: ctx));

    final lines = StringBuffer('Which service do you need?\n\n');
    for (var i = 0; i < services.take(6).length; i++) {
      final s = services[i];
      lines.writeln('${i + 1}. ${s.name} — from ₹${s.basePrice.toStringAsFixed(0)}');
    }
    lines.write('\nReply with a number, or describe what you need.');

    return AiMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}-svc',
      role: AiMessageRole.assistant,
      kind: AiMessageKind.serviceOptions,
      text: lines.toString().trim(),
      services: services.take(4).toList(),
    );
  }

  Future<AiMessage> _applyServiceAndReturn(CatalogServiceItem service) async {
    var ctx = state.context.copyWith(
      service: service,
      serviceCandidates: const [],
      phase: AiFlowPhase.needDate,
    );
    emit(state.copyWith(context: ctx));

    if (ctx.date == null) {
      return _text('Got it — ${service.name}. When do you need it? (e.g. tomorrow evening)');
    }
    return _searchVendors(ctx.copyWith(service: service));
  }

  Future<AiMessage> _searchVendors(AiBookingContext ctx) async {
    emit(state.copyWith(loadingLabel: 'Checking availability…'));

    if (!_isAuthenticated()) {
      emit(state.copyWith(needsAuthForBooking: true));
      return _text(
        'To check availability and book, please sign in first. You can still browse services here.',
      );
    }

    final addrResult = await _tools.resolveDefaultAddress();
    if (!addrResult.isSuccess || addrResult.data == null) {
      return _text(addrResult.userMessage ?? 'Please add a service address in your profile.');
    }
    final addr = addrResult.data!;

    var working = ctx.copyWith(
      addressId: addr.id,
      addressLabel: addr.summaryLine,
    );
    emit(state.copyWith(context: working));

    final vendors = await _tools.findVendorOptions(
      serviceId: working.service!.id,
      day: working.date!,
      pincode: addr.postalCode,
      city: addr.city,
      timeWindow: working.timeWindow,
      cheapest: working.sortCheapest,
    );

    if (!vendors.isSuccess || vendors.data == null) {
      return _text(vendors.userMessage ?? 'No availability found.');
    }

    final options = vendors.data!;
    working = working.copyWith(vendorOptions: options, phase: AiFlowPhase.needVendor);
    emit(state.copyWith(context: working));

    if (options.length == 1 || working.sortCheapest) {
      return _applyVendorAndReturn(options.first);
    }

    final buf = StringBuffer('I found ${options.length} available professionals:\n\n');
    for (var i = 0; i < options.length; i++) {
      final o = options[i];
      final slot = o.slots.first;
      buf.writeln(
        '${i + 1}. ${o.professional.displayName} — ₹${o.price.toStringAsFixed(0)} · ${slot.label}',
      );
    }
    buf.write('\nReply with a number, or say "cheapest one".');

    return AiMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}-vnd',
      role: AiMessageRole.assistant,
      kind: AiMessageKind.vendorOptions,
      text: buf.toString().trim(),
      vendorOptions: options,
    );
  }

  Future<AiMessage> _applyVendorAndReturn(AiVendorOption option) async {
    final slot = option.slots.first;
    final ctx = state.context.copyWith(
      selectedVendor: option.professional,
      selectedPrice: option.price,
      selectedSlot: slot,
      vendorOptions: const [],
      phase: AiFlowPhase.awaitingConfirmation,
      pendingConfirmation: true,
    );
    emit(state.copyWith(context: ctx));
    return AiMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}-confirm',
      role: AiMessageRole.assistant,
      kind: AiMessageKind.confirmation,
      text: _buildSummary(ctx),
      showConfirmActions: true,
    );
  }

  Future<AiMessage> _showBookings() async {
    if (!_isAuthenticated()) {
      emit(state.copyWith(needsAuthForBooking: true));
      return _text('Please sign in to view your bookings.');
    }
    emit(state.copyWith(loadingLabel: 'Loading your bookings…'));
    final result = await _tools.getMyBookings();
    if (!result.isSuccess || result.data == null) {
      return _text(result.userMessage ?? 'No bookings found.');
    }
    final list = result.data!;
    final buf = StringBuffer('Here are your recent bookings:\n\n');
    for (final b in list.take(5)) {
      buf.writeln('• ${b.serviceName} — ${b.status} — ${b.bookingCode}');
    }
    return AiMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}-bk',
      role: AiMessageRole.assistant,
      kind: AiMessageKind.bookingsList,
      text: buf.toString().trim(),
      bookings: list.take(5).toList(),
    );
  }

  String _buildSummary(AiBookingContext ctx) {
    return '''Please confirm your booking:

Service: ${ctx.service!.name}
Professional: ${ctx.selectedVendor!.displayName}
Date: ${_formatDate(ctx.date!)}
Time: ${ctx.selectedSlot!.label}
Address: ${ctx.addressLabel ?? '—'}
Estimated: ₹${ctx.selectedPrice!.toStringAsFixed(0)}

Payment is made directly to the service provider after completion.

Shall I confirm this booking?''';
  }

  AiMessage _text(String text) => AiMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}-t',
        role: AiMessageRole.assistant,
        text: text,
      );

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
