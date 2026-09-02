import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/booking_routes.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../../../../shared/widgets/app_primitives.dart';
import '../../../../shared/widgets/booking_widgets.dart';
import '../../../../shared/widgets/search_and_header.dart';
import '../cubit/bookings_cubit.dart';

class CreateBookingPage extends StatelessWidget {
  const CreateBookingPage({
    super.key,
    required this.professionalId,
    required this.serviceId,
    required this.professionalName,
    required this.serviceName,
  });

  final String professionalId;
  final String serviceId;
  final String professionalName;
  final String serviceName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CreateBookingCubit(
          context.read<BookingsApi>(),
          context.read<AddressApi>(),
          context.read<ProfessionalsApi>(),
          context.read<CatalogApi>(),
        );
        if (professionalId.isNotEmpty && serviceId.isNotEmpty) {
          cubit.bootstrap(
            professionalId: professionalId,
            serviceId: serviceId,
            professionalName: professionalName,
            serviceName: serviceName,
          );
        } else if (serviceId.isNotEmpty) {
          cubit.bootstrapFromService(
            serviceId: serviceId,
            serviceName: serviceName.isEmpty ? null : serviceName,
          );
        }
        return cubit;
      },
      child: const _BookingFlowView(),
    );
  }
}

class _BookingFlowView extends StatefulWidget {
  const _BookingFlowView();

  @override
  State<_BookingFlowView> createState() => _BookingFlowViewState();
}

class _BookingFlowViewState extends State<_BookingFlowView> {
  final _notes = TextEditingController();
  int _step = 0;
  bool _paymentAck = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<CreateBookingCubit, CreateBookingState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, state) {
        if (state.message == 'booked' && state.created != null) {
          context.go('/booking-confirmed', extra: state.created);
          return;
        }
        if (state.message != null && state.message != 'booked') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        if (state.status == CreateBookingStatus.loading ||
            state.status == CreateBookingStatus.initial) {
          return Scaffold(
            appBar: AppBar(title: Text(s.bookService)),
            body: LivoraLoading(message: s.loading),
          );
        }
        if (state.status == CreateBookingStatus.error) {
          return Scaffold(
            appBar: AppBar(title: Text(s.bookService)),
            body: EmptyState(
              message: state.message ?? s.offlineHint,
              actionLabel: s.retry,
              onAction: () {
                final cubit = context.read<CreateBookingCubit>();
                if (state.professionalId != null &&
                    state.professionalId!.isNotEmpty &&
                    state.serviceId != null) {
                  cubit.bootstrap(
                    professionalId: state.professionalId!,
                    serviceId: state.serviceId!,
                    professionalName: state.professionalName ?? '',
                    serviceName: state.serviceName ?? '',
                  );
                } else if (state.serviceId != null) {
                  cubit.bootstrapFromService(
                    serviceId: state.serviceId!,
                    serviceName: state.serviceName,
                  );
                }
              },
            ),
          );
        }

        return Scaffold(
          backgroundColor: Am5Colors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (_step > 0) {
                  setState(() => _step--);
                } else {
                  context.pop();
                }
              },
            ),
            title: Text(_stepTitle(_step)),
          ),
          body: Column(
            children: [
              _StepIndicator(step: _step),
              Expanded(child: _buildStep(context, state, s, theme)),
            ],
          ),
          bottomNavigationBar: _buildFooter(context, state, s),
        );
      },
    );
  }

  String _stepTitle(int step) => switch (step) {
        0 => 'Select date & time',
        1 => 'Delivery address',
        2 => 'Special instructions',
        3 => 'Summary & confirm',
        _ => 'Book service',
      };

  Widget _buildStep(
    BuildContext context,
    CreateBookingState state,
    LivoraStrings s,
    ThemeData theme,
  ) {
    switch (_step) {
      case 0:
        return ListView(
          padding: const EdgeInsets.only(bottom: Am5Spacing.xl),
          children: [
            _ServiceSummary(state: state),
            const SizedBox(height: Am5Spacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
              child: Text('Select date', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: Am5Spacing.sm),
            DateSelector(
              selected: state.day ?? DateTime.now(),
              onSelected: (d) => context.read<CreateBookingCubit>().selectDay(d),
            ),
            const SizedBox(height: Am5Spacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
              child: Text('Select time slot', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: Am5Spacing.sm),
            TimeSlotSelector(
              slots: state.slots,
              selected: state.selectedSlot,
              onSelected: (slot) => context.read<CreateBookingCubit>().selectSlot(slot),
            ),
          ],
        );
      case 1:
        return ListView(
          padding: const EdgeInsets.all(Am5Spacing.lg),
          children: [
            _ServiceSummary(state: state),
            const SizedBox(height: Am5Spacing.lg),
            Text(s.selectAddress, style: theme.textTheme.titleMedium),
            const SizedBox(height: Am5Spacing.md),
            if (state.addresses.isEmpty)
              AppButton(
                label: s.addAddress,
                outlined: true,
                onPressed: () async {
                  await context.push('/addresses/new');
                  if (context.mounted) {
                    await context.read<CreateBookingCubit>().reloadAddresses();
                  }
                },
              )
            else
              ...state.addresses.map((a) {
                final selected = state.selectedAddressId == a.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: Am5Spacing.sm),
                  child: Material(
                    color: selected ? Am5Colors.lightRed : Am5Colors.surface,
                    borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
                    child: InkWell(
                      onTap: () => context.read<CreateBookingCubit>().selectAddress(a.id),
                      borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
                      child: Padding(
                        padding: const EdgeInsets.all(Am5Spacing.lg),
                        child: Row(
                          children: [
                            Icon(
                              selected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: Am5Spacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.displayLabel, style: theme.textTheme.titleSmall),
                                  Text(a.summaryLine, style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      case 2:
        return ListView(
          padding: const EdgeInsets.all(Am5Spacing.lg),
          children: [
            _ServiceSummary(state: state),
            const SizedBox(height: Am5Spacing.lg),
            Text(s.bookingNotes, style: theme.textTheme.titleMedium),
            const SizedBox(height: Am5Spacing.sm),
            TextField(
              controller: _notes,
              maxLines: 4,
              decoration: InputDecoration(hintText: 'Any special instructions for the professional?'),
            ),
          ],
        );
      case 3:
        final addr = state.addresses
            .where((a) => a.id == state.selectedAddressId)
            .firstOrNull;
        return ListView(
          padding: const EdgeInsets.all(Am5Spacing.lg),
          children: [
            _SummaryCard(state: state, address: addr?.summaryLine),
            const SizedBox(height: Am5Spacing.lg),
            PaymentNoticeCard(
              acknowledged: _paymentAck,
              onAcknowledgeChanged: (v) => setState(() => _paymentAck = v),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget? _buildFooter(BuildContext context, CreateBookingState state, LivoraStrings s) {
    final canNext = switch (_step) {
      0 => state.selectedSlot != null,
      1 => state.selectedAddressId != null,
      2 => true,
      3 => _paymentAck && !state.submitting,
      _ => false,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Am5Spacing.lg),
        child: AppButton(
          label: _step == 3 ? s.confirmBooking : 'Continue',
          loading: state.submitting,
          onPressed: canNext
              ? () {
                  if (_step < 3) {
                    setState(() => _step++);
                  } else {
                    context.read<CreateBookingCubit>().submit(
                          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
                        );
                  }
                }
              : null,
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Am5Spacing.lg),
      child: Row(
        children: List.generate(4, (i) {
          final active = i <= step;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
              decoration: BoxDecoration(
                color: active ? theme.colorScheme.primary : Am5Colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ServiceSummary extends StatelessWidget {
  const _ServiceSummary({required this.state});

  final CreateBookingState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
      child: Container(
        padding: const EdgeInsets.all(Am5Spacing.lg),
        decoration: BoxDecoration(
          color: Am5Colors.lightRed,
          borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.serviceName ?? '', style: theme.textTheme.titleMedium),
            Text('with ${state.professionalName ?? ''}', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state, this.address});

  final CreateBookingState state;
  final String? address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Am5Spacing.lg),
      decoration: BoxDecoration(
        color: Am5Colors.surface,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
        boxShadow: [
          BoxShadow(color: Am5Colors.shadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking summary', style: theme.textTheme.titleMedium),
          const Divider(height: 24),
          _row('Service', state.serviceName ?? '', theme),
          _row('Professional', state.professionalName ?? '', theme),
          _row('Date', state.day?.toString().split(' ').first ?? '', theme),
          _row('Time', state.selectedSlot?.label ?? '', theme),
          if (address != null) _row('Address', address!, theme),
          const Divider(height: 24),
          Row(
            children: [
              Text('Estimated service charge', style: theme.textTheme.bodyMedium),
              const Spacer(),
              Text(
                'At completion',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pay directly to your service provider after the job is done.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: theme.textTheme.bodySmall)),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
