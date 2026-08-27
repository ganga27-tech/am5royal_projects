import re

with open("lib/features/products/presentation/widgets/india_hubs_map_view.dart", "r") as f:
    content = f.read()

new_class = """import 'dart:math';

final List<LatLng> indiaBorder = [
  LatLng(23.2, 68.6), LatLng(24.5, 68.9), LatLng(26.0, 70.0), LatLng(28.0, 71.5), 
  LatLng(30.0, 73.0), LatLng(32.0, 74.5), LatLng(34.0, 74.0), LatLng(35.5, 74.5), 
  LatLng(35.5, 77.0), LatLng(34.0, 78.5), LatLng(32.5, 78.5), LatLng(31.0, 79.5), 
  LatLng(29.5, 80.5), LatLng(28.0, 81.5), LatLng(27.5, 83.5), LatLng(27.0, 85.0), 
  LatLng(27.0, 88.0), LatLng(27.5, 88.5), LatLng(27.5, 92.0), LatLng(29.0, 94.0), 
  LatLng(28.0, 97.0), LatLng(27.0, 96.0), LatLng(25.0, 94.0), LatLng(23.5, 93.0), 
  LatLng(22.0, 93.0), LatLng(24.0, 91.5), LatLng(25.0, 90.0), LatLng(22.5, 88.5), 
  LatLng(21.5, 87.5), LatLng(20.5, 87.0), LatLng(19.0, 85.0), LatLng(17.0, 82.5), 
  LatLng(15.0, 80.0), LatLng(13.0, 80.2), LatLng(10.5, 79.8), LatLng(8.5, 78.2), 
  LatLng(8.1, 77.5), LatLng(8.5, 76.8), LatLng(10.0, 76.0), LatLng(12.0, 75.0), 
  LatLng(14.0, 74.5), LatLng(16.0, 73.5), LatLng(19.0, 72.8), LatLng(21.0, 72.5), 
  LatLng(21.5, 70.0), LatLng(22.5, 69.0),
];

class IndiaHubsMapView extends StatefulWidget {
  const IndiaHubsMapView({super.key});

  @override
  State<IndiaHubsMapView> createState() => _IndiaHubsMapViewState();
}

class _IndiaHubsMapViewState extends State<IndiaHubsMapView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _segmentLengths = [];
  double _totalLength = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < indiaBorder.length; i++) {
      LatLng p1 = indiaBorder[i];
      LatLng p2 = indiaBorder[(i + 1) % indiaBorder.length];
      double dx = p1.longitude - p2.longitude;
      double dy = p1.latitude - p2.latitude;
      double dist = sqrt(dx * dx + dy * dy);
      _segmentLengths.add(dist);
      _totalLength += dist;
    }
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LatLng _getInterpolatedPosition(double progress) {
    double targetDistance = progress * _totalLength;
    double currentDistance = 0;
    
    for (int i = 0; i < indiaBorder.length; i++) {
      if (currentDistance + _segmentLengths[i] >= targetDistance) {
        double remaining = targetDistance - currentDistance;
        double fraction = _segmentLengths[i] > 0 ? remaining / _segmentLengths[i] : 0;
        LatLng p1 = indiaBorder[i];
        LatLng p2 = indiaBorder[(i + 1) % indiaBorder.length];
        
        return LatLng(
          p1.latitude + (p2.latitude - p1.latitude) * fraction,
          p1.longitude + (p2.longitude - p1.longitude) * fraction,
        );
      }
      currentDistance += _segmentLengths[i];
    }
    return indiaBorder.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(21.5937, 78.9629), // Centered on India
          initialZoom: 4.8,
          minZoom: 4.2,
          maxZoom: 9.0,
          cameraConstraint: CameraConstraint.contain(
            bounds: LatLngBounds(
              LatLng(6.0, 68.0),  // South-West Boundary
              LatLng(36.0, 98.0), // North-East Boundary
            ),
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.am5royal.vendor',
          ),
          
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return MarkerLayer(
                markers: StateHubData.hubs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final hub = entry.value;
                  
                  // Distribute evenly along the border
                  double hubOffset = index / StateHubData.hubs.length;
                  double progress = (_controller.value + hubOffset) % 1.0;
                  LatLng animatedPosition = _getInterpolatedPosition(progress);
                  
                  return Marker(
                    point: animatedPosition,
                    width: 75.0,
                    height: 75.0,
                    child: GestureDetector(
                      onTap: () => _showHubDetails(context, hub),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _getMarkerColor(hub.markerType),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getIconForType(hub.markerType),
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F4C81).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
                            ),
                            child: Text(
                              hub.stateName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
"""

content = re.sub(r'class IndiaHubsMapView extends StatelessWidget \{.*?Widget build\(BuildContext context\) \{.*?(?=  Color _getMarkerColor)', new_class, content, flags=re.DOTALL)

with open("lib/features/products/presentation/widgets/india_hubs_map_view.dart", "w") as f:
    f.write(content)

