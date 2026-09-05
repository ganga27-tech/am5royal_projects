import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/voice/voice_search_launcher.dart';
import '../cubit/search_cubit.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SearchCubit(context.read<SearchApi>());
        cubit.bootstrap().then((_) {
          final q = initialQuery?.trim();
          if (q != null && q.isNotEmpty) {
            cubit.submit(query: q);
          }
        });
        return cubit;
      },
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final TextEditingController _controller;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<SearchCubit, SearchViewState>(
      listenWhen: (p, c) => p.query != c.query && c.query != _controller.text,
      listener: (context, state) {
        if (_controller.text != state.query) {
          _controller.value = TextEditingValue(
            text: state.query,
            selection: TextSelection.collapsed(offset: state.query.length),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LivoraSpacing.lg,
                    LivoraSpacing.md,
                    LivoraSpacing.lg,
                    LivoraSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.navExplore,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: LivoraSpacing.md),
                      _SearchField(
                        controller: _controller,
                        focusNode: _focus,
                        hint: s.searchHint,
                        showClear: state.query.isNotEmpty,
                        onChanged: context.read<SearchCubit>().onQueryChanged,
                        onSubmitted: (v) =>
                            context.read<SearchCubit>().submit(query: v),
                        onClear: () {
                          _controller.clear();
                          context.read<SearchCubit>().clearResults();
                          context.read<SearchCubit>().onQueryChanged('');
                        },
                        onSearch: () => context
                            .read<SearchCubit>()
                            .submit(query: _controller.text),
                        onMic: () async {
                          final query = await VoiceSearchLauncher.capture(context);
                          if (!context.mounted || query == null || query.isEmpty) {
                            return;
                          }
                          _runQuery(query);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(child: _body(context, state, s)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, SearchViewState state, LivoraStrings s) {
    if (state.bootStatus == SearchBootStatus.loading ||
        state.bootStatus == SearchBootStatus.initial) {
      return LivoraLoading(message: s.loading);
    }

    if (state.bootStatus == SearchBootStatus.error &&
        state.status == SearchStatus.idle) {
      return _MessageState(
        message: state.message ?? s.offlineHint,
        actionLabel: s.retry,
        onAction: () => context.read<SearchCubit>().bootstrap(),
      );
    }

    final suggest = state.suggest;
    if (suggest != null &&
        state.query.trim().length >= 2 &&
        state.status != SearchStatus.results) {
      return _SuggestList(
        suggest: suggest,
        onQuery: _runQuery,
        onService: _openService,
        onCategory: _openCategory,
      );
    }

    if (state.status == SearchStatus.searching) {
      return LivoraLoading(message: s.searching);
    }

    if (state.status == SearchStatus.error) {
      return _MessageState(
        message: state.message ?? s.offlineHint,
        actionLabel: s.retry,
        onAction: () => context.read<SearchCubit>().submit(),
      );
    }

    if (state.status == SearchStatus.results && state.result != null) {
      return _ResultsList(
        result: state.result!,
        sort: state.sort,
        onSort: (sort) => context.read<SearchCubit>().submit(sort: sort),
        onService: _openService,
        emptyLabel: s.searchEmpty,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LivoraSpacing.lg,
        LivoraSpacing.sm,
        LivoraSpacing.lg,
        LivoraSpacing.xxl,
      ),
      children: [
        if (state.popular.isNotEmpty) ...[
          Text(
            s.popularSearches,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: LivoraSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.popular
                .map(
                  (p) => _PopularChip(
                    label: p.query,
                    onTap: () => _runQuery(p.query),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: LivoraSpacing.xl),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                s.recentSearches,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            if (state.history.isNotEmpty)
              TextButton(
                onPressed: () => context.read<SearchCubit>().clearHistory(),
                child: Text(s.clearHistory),
              ),
          ],
        ),
        const SizedBox(height: LivoraSpacing.sm),
        if (state.history.isEmpty)
          _EmptyRecent(message: s.noRecentSearches)
        else
          ...state.history.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HistoryTile(
                query: h.query,
                onTap: () => _runQuery(h.query),
              ),
            ),
          ),
      ],
    );
  }

  void _runQuery(String q) {
    _controller.text = q;
    context.read<SearchCubit>().submit(query: q);
  }

  void _openService(String id) => context.push('/services/$id');

  void _openCategory(String id) => context.push('/categories/$id');
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.showClear,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onSearch,
    required this.onMic,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool showClear;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onSearch;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyLarge,
                cursorColor: theme.colorScheme.primary,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
            if (showClear)
              IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
            Material(
              color: Am5Colors.lightRed,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onMic,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.mic_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
         
          ],
        ),
      ),
    );
  }
}

class _PopularChip extends StatelessWidget {
  const _PopularChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Am5Colors.background,
            borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
          ),
          child: Icon(
            Icons.history_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(query, style: theme.textTheme.titleSmall),
        trailing: Icon(
          Icons.north_west_rounded,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: LivoraSpacing.lg,
        vertical: LivoraSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Am5Colors.background,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history_rounded,
            size: 22,
            color: theme.colorScheme.primary.withValues(alpha: 0.75),
          ),
          const SizedBox(width: LivoraSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(LivoraSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 40,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: LivoraSpacing.md),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: LivoraSpacing.lg),
          LivoraButton(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}

class _SuggestList extends StatelessWidget {
  const _SuggestList({
    required this.suggest,
    required this.onQuery,
    required this.onService,
    required this.onCategory,
  });

  final SearchSuggest suggest;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onService;
  final ValueChanged<String> onCategory;

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);
    final children = <Widget>[];

    for (final q in suggest.queries) {
      children.add(
        ListTile(
          leading: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
          title: Text(q),
          trailing: const Icon(Icons.north_west_rounded, size: 18),
          onTap: () => onQuery(q),
        ),
      );
    }
    for (final c in suggest.categories) {
      children.add(
        ListTile(
          leading: Icon(Icons.grid_view_rounded, color: theme.colorScheme.primary),
          title: Text(c.name),
          subtitle: Text(s.categories),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => onCategory(c.id),
        ),
      );
    }
    for (final svc in suggest.services) {
      children.add(
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Am5Colors.background,
              borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
            ),
            child: Icon(
              Icons.home_repair_service_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(svc.name),
          subtitle: Text('${s.fromPrice} ${svc.priceLabel}'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => onService(svc.id),
        ),
      );
    }

    if (children.isEmpty) {
      return Center(
        child: Text(
          s.searchEmpty,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: LivoraSpacing.sm),
      children: children,
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.result,
    required this.sort,
    required this.onSort,
    required this.onService,
    required this.emptyLabel,
  });

  final SearchPageResult result;
  final String sort;
  final ValueChanged<String> onSort;
  final ValueChanged<String> onService;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: LivoraSpacing.lg),
            children: [
              _SortChip(
                label: s.sortRelevance,
                value: 'relevance',
                group: sort,
                onSort: onSort,
              ),
              _SortChip(
                label: s.sortPopular,
                value: 'popular',
                group: sort,
                onSort: onSort,
              ),
              _SortChip(
                label: s.sortPriceAsc,
                value: 'price_asc',
                group: sort,
                onSort: onSort,
              ),
              _SortChip(
                label: s.sortPriceDesc,
                value: 'price_desc',
                group: sort,
                onSort: onSort,
              ),
              _SortChip(
                label: s.sortNewest,
                value: 'newest',
                group: sort,
                onSort: onSort,
              ),
            ],
          ),
        ),
        Expanded(
          child: result.items.isEmpty
              ? Center(
                  child: Text(
                    emptyLabel,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    LivoraSpacing.lg,
                    LivoraSpacing.sm,
                    LivoraSpacing.lg,
                    LivoraSpacing.xxl,
                  ),
                  itemCount: result.items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: LivoraSpacing.sm),
                  itemBuilder: (context, index) {
                    final svc = result.items[index];
                    return _ResultCard(
                      service: svc,
                      minutesLabel: s.minutes,
                      fromLabel: s.fromPrice,
                      onTap: () => onService(svc.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.service,
    required this.minutesLabel,
    required this.fromLabel,
    required this.onTap,
  });

  final CatalogServiceItem service;
  final String minutesLabel;
  final String fromLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
          ),
          clipBehavior: Clip.antiAlias,
          child: service.imageUrl != null
              ? Image.network(
                  service.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.home_repair_service_outlined,
                    color: theme.colorScheme.primary,
                  ),
                )
              : Icon(
                  Icons.home_repair_service_outlined,
                  color: theme.colorScheme.primary,
                ),
        ),
        title: Text(
          service.name,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          [
            if (service.categoryName != null && service.categoryName!.isNotEmpty)
              service.categoryName!,
            '$fromLabel ${service.priceLabel}',
            '${service.durationMinutes} $minutesLabel',
          ].join(' · '),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.value,
    required this.group,
    required this.onSort,
  });

  final String label;
  final String value;
  final String group;
  final ValueChanged<String> onSort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = group == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onSort(value),
        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected
                  ? theme.colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
        side: BorderSide(
          color: selected
              ? theme.colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
        ),
      ),
    );
  }
}
