import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

import '../../../../core/auth/login_guard.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_decorations.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../../../../core/voice/voice_search_launcher.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../bookings/presentation/widgets/booking_otp_sheet.dart';
import '../../data/ai_assistant_tools.dart';
import '../../domain/ai_booking_context.dart';
import '../cubit/ai_assistant_cubit.dart';
import '../../../../shared/widgets/service_widgets.dart';

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiAssistantCubit(
        tools: AiAssistantTools(
          searchApi: context.read<SearchApi>(),
          professionalsApi: context.read<ProfessionalsApi>(),
          bookingsApi: context.read<BookingsApi>(),
          addressApi: context.read<AddressApi>(),
        ),
        isAuthenticated: () =>
            context.read<AuthBloc>().state.status == AuthStatus.authenticated,
      ),
      child: const _AiAssistantView(),
    );
  }
}

class _AiAssistantView extends StatefulWidget {
  const _AiAssistantView();

  @override
  State<_AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<_AiAssistantView> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  static const _suggestions = [
    'My AC is not cooling — need someone tomorrow evening',
    'Cheapest deep cleaning service tomorrow',
    'Book home cleaning for this weekend',
    'Find a verified electrician near me',
    'Show my bookings',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onConfirmBooking() async {
    final cubit = context.read<AiAssistantCubit>();
    if (!LoginGuard.isAuthenticated(context)) {
      final ok = await LoginGuard.ensureLoggedIn(
        context,
        message: 'Sign in to confirm your booking.',
        redirectTo: '/assistant',
      );
      if (!ok || !context.mounted) return;
    }
    final verified = await BookingOtpSheet.show(context);
    if (!context.mounted || !verified) return;
    await cubit.confirmBooking();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AiAssistantCubit, AiAssistantState>(
      listenWhen: (p, c) =>
          p.messages.length != c.messages.length || p.needsAuthForBooking != c.needsAuthForBooking,
      listener: (context, state) {
        _scrollToEnd();
        if (state.needsAuthForBooking) {
          context.read<AiAssistantCubit>().clearAuthFlag();
          LoginGuard.ensureLoggedIn(
            context,
            message: 'Sign in to continue with booking.',
            redirectTo: '/assistant',
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Am5Colors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(Am5Spacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: Am5Decorations.brandGradient(),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: Am5Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI Assistant', style: theme.textTheme.titleLarge),
                            Text(
                              'Search, recommend & book in one place',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.messages.length <= 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
                    child: Wrap(
                      spacing: Am5Spacing.sm,
                      runSpacing: Am5Spacing.sm,
                      children: _suggestions.map((s) {
                        return ActionChip(
                          label: Text(s, style: theme.textTheme.bodySmall),
                          backgroundColor: Am5Colors.lightRed,
                          onPressed: state.loading
                              ? null
                              : () => context.read<AiAssistantCubit>().sendSuggested(s),
                        );
                      }).toList(),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(Am5Spacing.lg),
                    itemCount: state.messages.length + (state.loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.messages.length) {
                        return _TypingBubble(label: state.loadingLabel);
                      }
                      return _MessageBubble(
                        message: state.messages[index],
                        onConfirm: _onConfirmBooking,
                        onCancel: () => context.read<AiAssistantCubit>().cancelBookingFlow(),
                        onSelectService: (i) =>
                            context.read<AiAssistantCubit>().selectService(i),
                        onSelectVendor: (i) =>
                            context.read<AiAssistantCubit>().selectVendor(i),
                      );
                    },
                  ),
                ),
                _InputBar(
                  controller: _controller,
                  loading: state.loading || state.bookingInProgress,
                  onSend: () {
                    context.read<AiAssistantCubit>().send(_controller.text);
                    _controller.clear();
                  },
                  onMic: () async {
                    final query = await VoiceSearchLauncher.capture(context);
                    if (!context.mounted || query == null || query.trim().isEmpty) return;
                    context.read<AiAssistantCubit>().send(query.trim());
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    required this.onSelectService,
    required this.onSelectVendor,
  });

  final AiMessage message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final ValueChanged<int> onSelectService;
  final ValueChanged<int> onSelectVendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == AiMessageRole.user;

    if (message.kind == AiMessageKind.bookingSuccess && message.booking != null) {
      return _BookingSuccessCard(booking: message.booking!);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: Am5Spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
          if (!isUser) const SizedBox(width: Am5Spacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(Am5Spacing.md),
                  decoration: BoxDecoration(
                    color: isUser ? theme.colorScheme.primary : Am5Colors.surface,
                    borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
                    boxShadow: isUser
                        ? null
                        : [
                            BoxShadow(
                              color: Am5Colors.shadow,
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUser ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (message.services.isNotEmpty) ...[
                  const SizedBox(height: Am5Spacing.sm),
                  ...message.services.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: Am5Spacing.sm),
                      child: ServiceCard(
                        service: e.value,
                        compact: true,
                        onTap: () => context.push('/services/${e.value.id}'),
                        onBook: () => onSelectService(e.key),
                      ),
                    ),
                  ),
                ],
                if (message.vendorOptions.isNotEmpty) ...[
                  const SizedBox(height: Am5Spacing.sm),
                  ...message.vendorOptions.asMap().entries.map(
                    (e) => _VendorOptionTile(
                      index: e.key,
                      option: e.value,
                      onTap: () => onSelectVendor(e.key),
                    ),
                  ),
                ],
                if (message.showConfirmActions) ...[
                  const SizedBox(height: Am5Spacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: onConfirm,
                          child: const Text('Confirm booking'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: onCancel,
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
                if (message.bookings.isNotEmpty) ...[
                  const SizedBox(height: Am5Spacing.sm),
                  OutlinedButton(
                    onPressed: () => context.go('/bookings'),
                    child: const Text('View all bookings'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorOptionTile extends StatelessWidget {
  const _VendorOptionTile({
    required this.index,
    required this.option,
    required this.onTap,
  });

  final int index;
  final AiVendorOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slot = option.slots.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: Am5Spacing.sm),
      child: Material(
        color: Am5Colors.surface,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(Am5Spacing.md),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: Am5Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.professional.displayName,
                          style: theme.textTheme.titleSmall),
                      Text(
                        '${slot.label} · ₹${option.price.toStringAsFixed(0)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingSuccessCard extends StatelessWidget {
  const _BookingSuccessCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Am5Spacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Am5Spacing.lg),
        decoration: BoxDecoration(
          color: Am5Colors.surface,
          borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Booking confirmed', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: Am5Spacing.md),
            Text(booking.serviceName, style: theme.textTheme.titleSmall),
            if (booking.professionalName != null)
              Text('Professional: ${booking.professionalName}'),
            Text('Booking ID: #${booking.bookingCode}'),
            if (booking.priceAmount > 0) Text('Estimated: ${booking.priceLabel}'),
            const SizedBox(height: Am5Spacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.go('/bookings'),
                    child: const Text('View booking'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Home'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Am5Spacing.md),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: Am5Spacing.sm),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.loading,
    required this.onSend,
    required this.onMic,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSend;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Am5Spacing.lg,
        Am5Spacing.sm,
        Am5Spacing.lg,
        Am5Spacing.lg,
      ),
      decoration: BoxDecoration(
        color: Am5Colors.surface,
        boxShadow: [
          BoxShadow(color: Am5Colors.shadow, blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: loading ? null : onMic,
            icon: Icon(Icons.mic_rounded, color: theme.colorScheme.primary),
            tooltip: 'Voice input',
          ),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ask anything…',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(
            onPressed: loading ? null : onSend,
            icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
