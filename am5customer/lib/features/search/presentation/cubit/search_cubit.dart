import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

class SearchCubit extends Cubit<SearchViewState> {
  SearchCubit(this._api) : super(const SearchViewState.idle());

  final SearchApi _api;
  Timer? _debounce;
  int _suggestSeq = 0;

  Future<void> bootstrap() async {
    emit(state.copyWith(bootStatus: SearchBootStatus.loading, clearMessage: true));
    try {
      final popular = await _api.popular();
      List<SearchHistoryItem> history = const [];
      try {
        history = await _api.history();
      } catch (_) {
        // History requires auth; ignore if unavailable.
      }
      emit(
        state.copyWith(
          bootStatus: SearchBootStatus.ready,
          popular: popular,
          history: history,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(bootStatus: SearchBootStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(bootStatus: SearchBootStatus.error, message: 'Failed to load search'));
    }
  }

  void onQueryChanged(String value) {
    final q = value.trim();
    emit(state.copyWith(query: value, clearSuggest: q.length < 2));
    _debounce?.cancel();
    if (q.length < 2) return;
    _debounce = Timer(const Duration(milliseconds: 280), () => _suggest(q));
  }

  Future<void> _suggest(String q) async {
    final seq = ++_suggestSeq;
    try {
      final suggest = await _api.suggest(q: q);
      if (seq != _suggestSeq || isClosed) return;
      emit(state.copyWith(suggest: suggest));
    } catch (_) {
      if (seq != _suggestSeq || isClosed) return;
      emit(state.copyWith(clearSuggest: true));
    }
  }

  Future<void> submit({String? query, String? sort}) async {
    final q = (query ?? state.query).trim();
    final nextSort = sort ?? state.sort;
    emit(
      state.copyWith(
        query: query ?? state.query,
        status: SearchStatus.searching,
        sort: nextSort,
        clearSuggest: true,
        clearMessage: true,
      ),
    );
    try {
      final result = await _api.search(q: q.isEmpty ? null : q, sort: nextSort);
      List<SearchHistoryItem> history = state.history;
      if (q.isNotEmpty) {
        try {
          history = await _api.history();
        } catch (_) {}
      }
      emit(
        state.copyWith(
          status: SearchStatus.results,
          result: result,
          history: history,
          clearSuggest: true,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: SearchStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: SearchStatus.error, message: 'Search failed'));
    }
  }

  Future<void> clearHistory() async {
    try {
      await _api.clearHistory();
      emit(state.copyWith(history: const []));
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }

  void clearResults() {
    emit(
      state.copyWith(
        status: SearchStatus.idle,
        clearResult: true,
        clearSuggest: true,
        query: '',
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

enum SearchBootStatus { initial, loading, ready, error }

enum SearchStatus { idle, searching, results, error }

class SearchViewState extends Equatable {
  const SearchViewState({
    required this.bootStatus,
    required this.status,
    required this.query,
    required this.sort,
    this.popular = const [],
    this.history = const [],
    this.suggest,
    this.result,
    this.message,
  });

  const SearchViewState.idle()
      : this(
          bootStatus: SearchBootStatus.initial,
          status: SearchStatus.idle,
          query: '',
          sort: 'relevance',
        );

  final SearchBootStatus bootStatus;
  final SearchStatus status;
  final String query;
  final String sort;
  final List<PopularSearch> popular;
  final List<SearchHistoryItem> history;
  final SearchSuggest? suggest;
  final SearchPageResult? result;
  final String? message;

  SearchViewState copyWith({
    SearchBootStatus? bootStatus,
    SearchStatus? status,
    String? query,
    String? sort,
    List<PopularSearch>? popular,
    List<SearchHistoryItem>? history,
    SearchSuggest? suggest,
    SearchPageResult? result,
    String? message,
    bool clearMessage = false,
    bool clearSuggest = false,
    bool clearResult = false,
  }) {
    return SearchViewState(
      bootStatus: bootStatus ?? this.bootStatus,
      status: status ?? this.status,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      popular: popular ?? this.popular,
      history: history ?? this.history,
      suggest: clearSuggest ? null : (suggest ?? this.suggest),
      result: clearResult ? null : (result ?? this.result),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props =>
      [bootStatus, status, query, sort, popular, history, suggest, result, message];
}
