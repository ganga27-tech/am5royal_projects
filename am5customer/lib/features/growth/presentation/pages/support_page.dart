import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  bool _loading = true;
  String? _error;
  List<SupportTicket> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await context.read<GrowthApi>().listTickets();
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } on Failure catch (f) {
      if (mounted) {
        setState(() {
          _error = f.message;
          _loading = false;
        });
      }
    }
  }

  Future<void> _create() async {
    final s = LivoraStrings.of(context);

    final draft = await showModalBottomSheet<_TicketDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CreateTicketSheet(),
    );

    if (draft == null || !mounted) return;

    try {
      await context.read<GrowthApi>().createTicket(
            subject: draft.subject,
            body: draft.body,
          );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.ticketCreated)),
        );
      }
    } on Failure catch (f) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      }
    }
  }

  Future<void> _openTicket(SupportTicket ticket) async {
    final s = LivoraStrings.of(context);
    try {
      final detail = await context.read<GrowthApi>().getTicket(ticket.id);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.45,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: LivoraSpacing.md),
                    Text(
                      detail.ticketCode,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.subject,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: LivoraSpacing.sm),
                    Wrap(
                      spacing: 8,
                      children: [
                        _StatusChip(label: detail.status),
                        _StatusChip(label: detail.priority, muted: true),
                      ],
                    ),
                    const SizedBox(height: LivoraSpacing.lg),
                    Text(
                      s.ticketConversation,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: LivoraSpacing.sm),
                    ...detail.messages.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Align(
                          alignment: m.isStaff
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 320),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: m.isStaff
                                  ? Am5Colors.background
                                  : CustomerBrand.iconTileBg(context),
                              borderRadius: BorderRadius.circular(
                                LivoraSpacing.radii.lg,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.isStaff ? s.support : s.ticketYou,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(m.body, style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } on Failure catch (f) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Am5Colors.background,
      appBar: AppBar(
        title: Text(s.support),
        backgroundColor: Am5Colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add_rounded),
        label: Text(s.createTicket),
      ),
      body: _loading
          ? LivoraLoading(message: s.loading)
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(LivoraSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 40,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: LivoraSpacing.md),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: LivoraSpacing.lg),
                      LivoraButton(label: s.retry, onPressed: _load),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: theme.colorScheme.primary,
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(LivoraSpacing.xl),
                          children: [
                            const SizedBox(height: 80),
                            Container(
                              padding: const EdgeInsets.all(LivoraSpacing.xl),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(
                                  LivoraSpacing.radii.xl,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.support_agent_outlined,
                                    size: 40,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(height: LivoraSpacing.md),
                                  Text(
                                    s.supportEmpty,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: LivoraSpacing.lg),
                                  LivoraButton(
                                    label: s.createTicket,
                                    onPressed: _create,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            LivoraSpacing.lg,
                            LivoraSpacing.sm,
                            LivoraSpacing.lg,
                            LivoraSpacing.xxl + 56,
                          ),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: LivoraSpacing.sm),
                          itemBuilder: (context, i) {
                            final t = _items[i];
                            return Material(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                LivoraSpacing.radii.lg,
                              ),
                              child: ListTile(
                                onTap: () => _openTicket(t),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: CustomerBrand.iconTileBg(context),
                                    borderRadius: BorderRadius.circular(
                                      LivoraSpacing.radii.md,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.confirmation_number_outlined,
                                    color: theme.colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                                title: Text(
                                  t.subject,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  '${t.ticketCode} · ${t.status}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}

class _TicketDraft {
  const _TicketDraft({required this.subject, required this.body});

  final String subject;
  final String body;
}

class _CreateTicketSheet extends StatefulWidget {
  const _CreateTicketSheet();

  @override
  State<_CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<_CreateTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subject;
  late final TextEditingController _body;

  @override
  void initState() {
    super.initState();
    _subject = TextEditingController();
    _body = TextEditingController();
  }

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      _TicketDraft(
        subject: _subject.text.trim(),
        body: _body.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: LivoraSpacing.md),
                  Text(
                    s.createTicket,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.createTicketHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: LivoraSpacing.lg),
                  TextFormField(
                    controller: _subject,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: s.ticketSubject,
                      hintText: s.ticketSubjectHint,
                    ),
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? s.requiredField
                        : null,
                  ),
                  const SizedBox(height: LivoraSpacing.md),
                  TextFormField(
                    controller: _body,
                    minLines: 4,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: s.ticketMessage,
                      hintText: s.ticketMessageHint,
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? s.requiredField
                        : null,
                  ),
                  const SizedBox(height: LivoraSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(s.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(s.submitTicket),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: muted
            ? Am5Colors.background
            : CustomerBrand.iconTileBg(context),
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: muted
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
