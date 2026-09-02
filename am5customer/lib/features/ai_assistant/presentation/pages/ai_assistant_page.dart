import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

import '../../../../core/booking_routes.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_decorations.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../../../../shared/widgets/app_primitives.dart';
import '../../../../shared/widgets/service_widgets.dart';
import '../cubit/ai_assistant_cubit.dart';

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiAssistantCubit(
        context.read<SearchApi>(),
        context.read<CatalogApi>(),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AiAssistantCubit, AiAssistantState>(
      listenWhen: (p, c) => p.messages.length != c.messages.length,
      listener: (_, _) => _scrollToEnd(),
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
                          onPressed: () => context.read<AiAssistantCubit>().sendSuggested(s),
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
                        return _TypingBubble();
                      }
                      final msg = state.messages[index];
                      return _MessageBubble(message: msg);
                    },
                  ),
                ),
                _InputBar(
                  controller: _controller,
                  loading: state.loading,
                  onSend: () {
                    context.read<AiAssistantCubit>().send(_controller.text);
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
  const _MessageBubble({required this.message});

  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == AiMessageRole.user;
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
                  ...message.services.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: Am5Spacing.sm),
                      child: ServiceCard(
                        service: s,
                        compact: true,
                        onTap: () => context.push('/services/${s.id}'),
                        onBook: () => openServiceBookingById(
                          context,
                          serviceId: s.id,
                          serviceName: s.name,
                        ),
                      ),
                    ),
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

class _TypingBubble extends StatelessWidget {
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
          Text('Thinking…', style: Theme.of(context).textTheme.bodySmall),
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
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.send_rounded, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
