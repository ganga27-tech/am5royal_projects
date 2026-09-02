import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:am5_ui/am5_ui.dart';

/// Returns selected `LatLng` via `Navigator.pop`.
class MapPinPickerPage extends StatefulWidget {
  const MapPinPickerPage({
    super.key,
    this.initialLatitude = 12.9716,
    this.initialLongitude = 77.5946,
  });

  final double initialLatitude;
  final double initialLongitude;

  @override
  State<MapPinPickerPage> createState() => _MapPinPickerPageState();
}

class _MapPinPickerPageState extends State<MapPinPickerPage> {
  late LatLng _pin;
  final _controller = MapController();

  @override
  void initState() {
    super.initState();
    _pin = LatLng(widget.initialLatitude, widget.initialLongitude);
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return LivoraScaffold(
      title: s.pickOnMap,
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: _pin,
                initialZoom: 15,
                onTap: (_, latLng) => setState(() => _pin = latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'app.livora.customer',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pin,
                      width: 48,
                      height: 48,
                      child: const Icon(Icons.location_on, color: Color(0xFFC44536), size: 42),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('${_pin.latitude.toStringAsFixed(5)}, ${_pin.longitude.toStringAsFixed(5)}'),
          const SizedBox(height: 12),
          LivoraButton(
            label: s.save,
            onPressed: () => Navigator.of(context).pop(_pin),
          ),
        ],
      ),
    );
  }
}
