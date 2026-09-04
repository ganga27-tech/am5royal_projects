import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_ui/am5_ui.dart';

import '../cubit/professionals_cubit.dart';

class ProfessionalDetailPage extends StatelessWidget {
  const ProfessionalDetailPage({
    super.key,
    required this.professionalId,
    this.serviceId,
  });

  final String professionalId;
  final String? serviceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfessionalDetailCubit(
        context.read<ProfessionalsApi>(),
        professionalId,
        serviceId: serviceId,
      )..load(),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView();

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  int _rating = 5;
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return BlocConsumer<ProfessionalDetailCubit, ProfessionalDetailState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, state) {
        final text = state.message == 'review_saved' ? s.reviewSubmitted : state.message!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
        context.read<ProfessionalDetailCubit>().clearMessage();
        if (state.message == 'review_saved') {
          _title.clear();
          _body.clear();
        }
      },
      builder: (context, state) {
        if (state.status == ProfessionalDetailStatus.loading ||
            state.status == ProfessionalDetailStatus.initial) {
          return LivoraScaffold(title: s.professionals, body: LivoraLoading(message: s.loading));
        }
        if (state.status == ProfessionalDetailStatus.error || state.professional == null) {
          return LivoraScaffold(
            title: s.professionals,
            body: Column(
              children: [
                Text(state.message ?? s.offlineHint),
                const SizedBox(height: 16),
                LivoraButton(
                  label: s.retry,
                  onPressed: () => context.read<ProfessionalDetailCubit>().load(),
                ),
              ],
            ),
          );
        }
        final p = state.professional!;
        return Scaffold(
          appBar: AppBar(title: Text(p.displayName)),
          body: RefreshIndicator(
            onRefresh: () => context.read<ProfessionalDetailCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(LivoraSpacing.lg),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: p.hasAvatar ? NetworkImage(p.avatarUrl!) : null,
                      child: !p.hasAvatar ? Text(p.displayName.substring(0, 1)) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(p.displayName, style: Theme.of(context).textTheme.titleLarge),
                              ),
                              if (p.isVerified)
                                Icon(Icons.verified, color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                          if (p.headline != null) Text(p.headline!),
                          Text('★ ${p.ratingLabel} · ${p.yearsExperience} ${s.yearsExp}'),
                          Text('${p.city ?? ''} · ${p.jobsCompleted} ${s.jobsCompleted}'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (p.bio != null) ...[
                  const SizedBox(height: 16),
                  Text(p.bio!),
                ],
                if (p.skills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(s.skills, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.skills
                        .map(
                          (sk) => ActionChip(
                            label: Text(sk.serviceName ?? sk.serviceId),
                            onPressed: () {
                              final params = {
                                'professional_id': p.id,
                                'service_id': sk.serviceId,
                                'professional_name': p.displayName,
                                'service_name': sk.serviceName ?? '',
                              };
                              final q = params.entries
                                  .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
                                  .join('&');
                              context.push('/book?$q');
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(s.bookService, style: Theme.of(context).textTheme.bodySmall),
                ],
                const SizedBox(height: 24),
                Text(s.reviews, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (state.reviews.isEmpty)
                  Text(s.noReviews)
                else
                  ...state.reviews.map(
                    (r) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${'★' * r.rating}  ${r.title ?? ''}'),
                      subtitle: Text('${r.reviewerName ?? ''} · ${r.body ?? ''}'),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(s.writeReview, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      onPressed: () => setState(() => _rating = i + 1),
                      icon: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                TextField(controller: _title, decoration: InputDecoration(labelText: s.reviewTitle)),
                TextField(controller: _body, decoration: InputDecoration(labelText: s.reviewBody), maxLines: 3),
                const SizedBox(height: 12),
                LivoraButton(
                  label: s.submitReview,
                  onPressed: state.submitting
                      ? null
                      : () => context.read<ProfessionalDetailCubit>().submitReview(
                            rating: _rating,
                            title: _title.text.trim().isEmpty ? null : _title.text.trim(),
                            body: _body.text.trim().isEmpty ? null : _body.text.trim(),
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
