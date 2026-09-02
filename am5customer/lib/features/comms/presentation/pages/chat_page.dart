import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_ui/am5_ui.dart';

import '../cubit/chat_cubit.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(context.read<CommsApi>(), bookingId: bookingId)..load(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return BlocConsumer<ChatCubit, ChatViewState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, state) {
        final text = switch (state.message) {
          'call_started' => s.callConnecting,
          'call_ended' => s.endCall,
          _ => state.message!,
        };
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
        context.read<ChatCubit>().clearMessage();
      },
      builder: (context, state) {
        return LivoraScaffold(
          title: state.thread?.serviceName ?? s.chat,
          actions: [
            IconButton(
              tooltip: s.voiceCall,
              onPressed: state.status == ChatStatus.ready
                  ? () => context.read<ChatCubit>().startCall()
                  : null,
              icon: const Icon(Icons.call),
            ),
          ],
          body: _body(context, state, s),
        );
      },
    );
  }

  Widget _body(BuildContext context, ChatViewState state, LivoraStrings s) {
    if (state.status == ChatStatus.loading || state.status == ChatStatus.initial) {
      return LivoraLoading(message: s.loading);
    }
    if (state.status == ChatStatus.error) {
      return Column(
        children: [
          Text(state.message ?? s.offlineHint),
          LivoraButton(label: s.retry, onPressed: () => context.read<ChatCubit>().load()),
        ],
      );
    }

    return Column(
      children: [
        if (state.activeCall != null)
          Material(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.phone_in_talk),
              title: Text(
                state.activeCall!.status == 'active' ? s.callActive : s.callConnecting,
              ),
              subtitle: Text('${state.activeCall!.provider} · ${state.activeCall!.roomId}'),
              trailing: IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: () => context.read<ChatCubit>().endCall(),
              ),
            ),
          ),
        Expanded(
          child: state.messages.isEmpty
              ? Center(child: Text(s.chatsEmpty))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final m = state.messages[index];
                    final mine = state.thread != null &&
                        m.senderUserId == state.thread!.customerUserId;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: mine
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m.body),
                      ),
                    );
                  },
                ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: s.typeMessage),
                onSubmitted: (_) => _send(context),
              ),
            ),
            IconButton(
              onPressed: state.sending ? null : () => _send(context),
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }

  void _send(BuildContext context) {
    final text = _controller.text;
    _controller.clear();
    context.read<ChatCubit>().send(text);
  }
}
