import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_ui/am5_ui.dart';

import '../cubit/professionals_cubit.dart';

class ProfessionalsListPage extends StatelessWidget {
  const ProfessionalsListPage({super.key, this.serviceId, this.city});

  final String? serviceId;
  final String? city;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProfessionalsCubit(context.read<ProfessionalsApi>());
        cubit.load(serviceId: serviceId, city: city);
        return cubit;
      },
      child: const _ListView(),
    );
  }
}

class _ListView extends StatefulWidget {
  const _ListView();

  @override
  State<_ListView> createState() => _ListViewState();
}

class _ListViewState extends State<_ListView> {
  final _query = TextEditingController();
  final _city = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return BlocBuilder<ProfessionalsCubit, ProfessionalsViewState>(
      builder: (context, state) {
        return LivoraScaffold(
          title: s.professionals,
          body: Column(
            children: [
              TextField(
                controller: _query,
                decoration: InputDecoration(
                  hintText: s.searchProfessionals,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => context.read<ProfessionalsCubit>().load(
                          q: _query.text,
                          city: _city.text.isEmpty ? null : _city.text,
                        ),
                  ),
                ),
                onSubmitted: (v) => context.read<ProfessionalsCubit>().load(
                      q: v,
                      city: _city.text.isEmpty ? null : _city.text,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _city,
                decoration: InputDecoration(hintText: s.filterByCity, prefixIcon: const Icon(Icons.location_city)),
                onSubmitted: (v) => context.read<ProfessionalsCubit>().load(
                      q: _query.text,
                      city: v.isEmpty ? null : v,
                    ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SortChip(label: s.sortByRating, value: 'rating', group: state.sort),
                    _SortChip(label: s.sortByExperience, value: 'experience', group: state.sort),
                    _SortChip(label: s.sortByJobs, value: 'jobs', group: state.sort),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _body(context, state, s)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, ProfessionalsViewState state, LivoraStrings s) {
    if (state.status == ProfessionalsStatus.loading || state.status == ProfessionalsStatus.initial) {
      return LivoraLoading(message: s.loading);
    }
    if (state.status == ProfessionalsStatus.error) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.message ?? s.offlineHint),
          const SizedBox(height: 16),
          LivoraButton(label: s.retry, onPressed: () => context.read<ProfessionalsCubit>().load()),
        ],
      );
    }
    if (state.items.isEmpty) {
      return Center(child: Text(s.professionalsEmpty));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ProfessionalsCubit>().load(),
      child: ListView.separated(
        itemCount: state.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final p = state.items[index];
          return Card(
            child: ListTile(
              onTap: () => context.push('/vendors/${p.id}'),
              leading: CircleAvatar(
                backgroundImage: p.hasAvatar ? NetworkImage(p.avatarUrl!) : null,
                child: !p.hasAvatar ? Text(p.displayName.substring(0, 1)) : null,
              ),
              title: Row(
                children: [
                  Flexible(child: Text(p.displayName)),
                  if (p.isVerified) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.verified, size: 16, color: Theme.of(context).colorScheme.primary),
                  ],
                ],
              ),
              subtitle: Text(
                '${p.headline ?? ''} · ${p.city ?? ''} · ★ ${p.ratingLabel}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.label, required this.value, required this.group});

  final String label;
  final String value;
  final String group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: group == value,
        onSelected: (_) => context.read<ProfessionalsCubit>().setSort(value),
      ),
    );
  }
}
