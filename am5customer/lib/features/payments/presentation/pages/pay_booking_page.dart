import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_ui/am5_ui.dart';

import '../cubit/payments_cubit.dart';

class PayBookingPage extends StatelessWidget {
  const PayBookingPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PayBookingCubit(
        context.read<PaymentsApi>(),
        context.read<BookingsApi>(),
        bookingId,
      )..load(),
      child: const _PayView(),
    );
  }
}

class _PayView extends StatefulWidget {
  const _PayView();

  @override
  State<_PayView> createState() => _PayViewState();
}

class _PayViewState extends State<_PayView> {
  final _coupon = TextEditingController();

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return BlocConsumer<PayBookingCubit, PayBookingState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, state) {
        if (state.message == 'paid') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.paymentSuccess)));
          context.go('/bookings');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
      },
      builder: (context, state) {
        return LivoraScaffold(
          title: s.payNow,
          body: state.status == PayBookingStatus.loading || state.status == PayBookingStatus.initial
              ? LivoraLoading(message: s.loading)
              : state.status == PayBookingStatus.error || state.booking == null
                  ? Column(
                      children: [
                        Text(state.message ?? s.offlineHint),
                        LivoraButton(label: s.retry, onPressed: () => context.read<PayBookingCubit>().load()),
                      ],
                    )
                  : ListView(
                      children: [
                        Text(state.booking!.serviceName, style: Theme.of(context).textTheme.titleLarge),
                        Text('${state.booking!.bookingCode} · ${state.booking!.priceLabel}'),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _coupon,
                          decoration: InputDecoration(
                            labelText: s.couponCode,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () =>
                                  context.read<PayBookingCubit>().applyCoupon(_coupon.text.trim()),
                            ),
                          ),
                        ),
                        if (state.quote != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              state.quote!.valid
                                  ? '${s.discount}: ₹${state.quote!.discountAmount.toStringAsFixed(0)}'
                                  : state.quote!.message,
                              style: TextStyle(
                                color: state.quote!.valid
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(s.useWallet),
                          subtitle: Text(
                            '${s.walletBalance}: ${state.wallet?.balanceLabel ?? '₹0'}',
                          ),
                          value: state.useWallet,
                          onChanged: (v) => context.read<PayBookingCubit>().toggleWallet(v),
                        ),
                        const SizedBox(height: 24),
                        LivoraButton(
                          label: s.confirmPayment,
                          onPressed: state.submitting ? null : () => context.read<PayBookingCubit>().pay(),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}
