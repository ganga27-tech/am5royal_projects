import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

enum AiMessageRole { user, assistant }

class AiMessage extends Equatable {
  const AiMessage({
    required this.id,
    required this.role,
    required this.text,
    this.services = const [],
    this.isTyping = false,
  });

  final String id;
  final AiMessageRole role;
  final String text;
  final List<CatalogServiceItem> services;
  final bool isTyping;

  @override
  List<Object?> get props => [id, role, text, services, isTyping];
}

class AiAssistantState extends Equatable {
  const AiAssistantState({
    this.messages = const [],
    this.loading = false,
    this.input = '',
  });

  final List<AiMessage> messages;
  final bool loading;
  final String input;

  AiAssistantState copyWith({
    List<AiMessage>? messages,
    bool? loading,
    String? input,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      input: input ?? this.input,
    );
  }

  @override
  List<Object?> get props => [messages, loading, input];
}

class AiAssistantCubit extends Cubit<AiAssistantState> {
  AiAssistantCubit(this._searchApi, this._catalogApi) : super(const AiAssistantState()) {
    _welcome();
  }

  final SearchApi _searchApi;
  final CatalogApi _catalogApi;

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

  void setInput(String value) => emit(state.copyWith(input: value));

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || state.loading) return;

    final userMsg = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: AiMessageRole.user,
      text: text,
    );
    emit(
      state.copyWith(
        messages: [...state.messages, userMsg],
        input: '',
        loading: true,
      ),
    );

  await Future<void>.delayed(const Duration(milliseconds: 600));

    try {
      final response = await _buildResponse(text);
      emit(
        state.copyWith(
          messages: [...state.messages, response],
          loading: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            AiMessage(
              id: '${DateTime.now().millisecondsSinceEpoch}-err',
              role: AiMessageRole.assistant,
              text: 'I couldn\'t process that right now. Try searching in Explore or browse categories on Home.',
            ),
          ],
          loading: false,
        ),
      );
    }
  }

  Future<AiMessage> _buildResponse(String text) async {
    final lower = text.toLowerCase();
    String query = text;
    String intent = 'search';

    if (lower.contains('ac') || lower.contains('cooling') || lower.contains('air conditioner')) {
      query = 'AC repair cooling';
      intent = 'ac';
    } else if (lower.contains('clean')) {
      query = 'deep cleaning home cleaning';
      intent = 'cleaning';
    } else if (lower.contains('plumb')) {
      query = 'plumbing';
      intent = 'plumbing';
    } else if (lower.contains('electric')) {
      query = 'electrical';
      intent = 'electrical';
    } else if (lower.contains('pest')) {
      query = 'pest control';
      intent = 'pest';
    } else if (lower.contains('beauty') || lower.contains('spa')) {
      query = 'beauty wellness';
      intent = 'beauty';
    }

    final result = await _searchApi.search(q: query, limit: 6);
    var services = List<CatalogServiceItem>.from(result.items);

    if (lower.contains('cheap') || lower.contains('cheapest') || lower.contains('budget')) {
      services.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    }

    String reply;
    if (services.isEmpty) {
      reply = 'I couldn\'t find exact matches. Try describing the problem (e.g. "AC not cooling") or browse Explore.';
    } else if (intent == 'ac') {
      reply = 'Sounds like an AC cooling issue. Here are appliance repair services that can help — pick one to book for tomorrow evening if slots are available.';
    } else if (lower.contains('tomorrow')) {
      reply = 'Here are services available for booking. Select one and I\'ll guide you through date & time selection.';
    } else if (lower.contains('cheap') || lower.contains('cheapest')) {
      reply = 'Here are the most affordable options sorted by starting price.';
    } else {
      reply = 'I found these services based on your request. Tap Book to continue.';
    }

    return AiMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}-ai',
      role: AiMessageRole.assistant,
      text: reply,
      services: services.take(4).toList(),
    );
  }

  Future<void> sendSuggested(String prompt) => send(prompt);
}
