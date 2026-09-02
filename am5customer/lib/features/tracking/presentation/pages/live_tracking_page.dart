import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_ui/am5_ui.dart';

import '../cubit/tracking_cubit.dart';

class LiveTrackingPage extends StatelessWidget {
  const LiveTrackingPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrackingCubit(context.read<TrackingApi>(), bookingId)..load(),
      child: const _TrackingView(),
    );
  }
}

class _TrackingView extends StatelessWidget {
  const _TrackingView();

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return BlocBuilder<TrackingCubit, TrackingViewState>(
      builder: (context, state) {
        return LivoraScaffold(
          title: s.liveTracking,
          body: _body(context, state, s),
        );
      },
    );
  }

  Widget _body(BuildContext context, TrackingViewState state, LivoraStrings s) {
    if (state.status == TrackingStatus.loading || state.status == TrackingStatus.initial) {
      return LivoraLoading(message: s.loading);
    }
    if (state.status == TrackingStatus.error) {
      return Column(
        children: [
          Text(state.message ?? s.offlineHint),
          const SizedBox(height: 16),
          LivoraButton(label: s.retry, onPressed: () => context.read<TrackingCubit>().load()),
        ],
      );
    }
    final snap = state.snapshot;
    if (snap == null || !snap.hasDestination) {
      return Center(child: Text(s.trackingUnavailable));
    }

    final dest = LatLng(snap.destinationLatitude!, snap.destinationLongitude!);
    final pro = snap.hasProfessional
        ? LatLng(snap.professionalLatitude!, snap.professionalLongitude!)
        : null;
    final center = pro ?? dest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'app.livora.customer',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: dest,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.place, color: Color(0xFF0B6E4F), size: 36),
                    ),
                    if (pro != null)
                      Marker(
                        point: pro,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.navigation, color: Color(0xFF1B4965), size: 32),
                      ),
                    ...state.pings.take(20).map(
                          (p) => Marker(
                            point: LatLng(p.latitude, p.longitude),
                            width: 10,
                            height: 10,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0x661B4965),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
                if (pro != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [pro, dest],
                        color: const Color(0xFF1B4965),
                        strokeWidth: 3,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          snap.destinationLabel ?? snap.bookingCode,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          snap.isLive
              ? (snap.trackingStatus == 'arrived' ? s.arrived : s.enRoute)
              : snap.trackingStatus,
        ),
        if (snap.etaMinutes != null || snap.distanceKm != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (snap.etaMinutes != null)
                Expanded(child: Text('${s.etaLabel}: ${snap.etaMinutes} min')),
              if (snap.distanceKm != null)
                Expanded(
                  child: Text('${s.distanceLabel}: ${snap.distanceKm!.toStringAsFixed(2)} km'),
                ),
            ],
          ),
        ],
        if (!snap.hasProfessional) ...[
          const SizedBox(height: 8),
          Text(s.trackingEmpty),
        ],
      ],
    );
  }
}
