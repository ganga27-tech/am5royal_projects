import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_ui/am5_ui.dart';

import '../cubit/notifications_cubit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsCubit(context.read<CommsApi>())..load(),
      child: const _NotifView(),
    );
  }
}

class _NotifView extends StatelessWidget {
  const _NotifView();

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return BlocBuilder<NotificationsCubit, NotificationsViewState>(
      builder: (context, state) {
        return LivoraScaffold(
          title: s.notifications,
          actions: [
            if (state.items.any((n) => n.isUnread))
              TextButton(
                onPressed: () => context.read<NotificationsCubit>().markAll(),
                child: Text(s.markAllRead),
              ),
          ],
          body: _body(context, state, s),
        );
      },
    );
  }

  Widget _body(BuildContext context, NotificationsViewState state, LivoraStrings s) {
    if (state.status == NotifStatus.loading || state.status == NotifStatus.initial) {
      return LivoraLoading(message: s.loading);
    }
    if (state.status == NotifStatus.error) {
      return Column(
        children: [
          Text(state.message ?? s.offlineHint),
          LivoraButton(label: s.retry, onPressed: () => context.read<NotificationsCubit>().load()),
        ],
      );
    }
    if (state.items.isEmpty) {
      return Center(child: Text(s.notificationsEmpty));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<NotificationsCubit>().load(),
      child: ListView.separated(
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final n = state.items[index];
          return ListTile(
            leading: Icon(
              n.isUnread ? Icons.notifications_active : Icons.notifications_none,
            ),
            title: Text(n.title, style: TextStyle(fontWeight: n.isUnread ? FontWeight.w600 : null)),
            subtitle: Text(n.body),
            onTap: n.isUnread ? () => context.read<NotificationsCubit>().markRead(n.id) : null,
          );
        },
      ),
    );
  }
}
