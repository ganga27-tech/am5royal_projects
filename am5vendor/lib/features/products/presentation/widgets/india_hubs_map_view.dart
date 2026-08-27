import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/datasources/state_hub_data.dart';
import '../../data/models/state_hub_model.dart';

class IndiaHubsMapView extends StatefulWidget {
  const IndiaHubsMapView({super.key});

  @override
  State<IndiaHubsMapView> createState() => _IndiaHubsMapViewState();
}

class _IndiaHubsMapViewState extends State<IndiaHubsMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9), // Light background matching map tiles
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(22.0, 79.0), // Center of India
          initialZoom: 4.8,
          minZoom: 4.0,
          maxZoom: 10.0,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.am5royal.vendor',
          ),
          MarkerLayer(
            markers: StateHubData.hubs.map((hub) {
              return Marker(
                point: hub.coordinate,
                width: 100,
                height: 100,
                child: GestureDetector(
                  onTap: () => _showHubDetails(context, hub),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Crown Logo
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.85, end: 1.15).animate(
                          CurvedAnimation(
                            parent: _pulseController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFFFD700),
                                width: 2), // Gold border
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded, // Crown logo
                            color: Color(0xFFFFC107), // Gold color
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // State Name Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF0F4C81).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          hub.stateName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showHubDetails(BuildContext context, StateHub hub) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hub.stateName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F4C81),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Primary Hub: ${hub.hubCity}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFFFC107),
                      size: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE2E8F0), thickness: 1.5),
              const SizedBox(height: 20),

              // Analytics details
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticTile(
                      icon: Icons.storefront_rounded,
                      title: 'Active Vendors',
                      value: hub.activeVendors.toString(),
                      color: const Color(0xFF007AFF),
                    ),
                  ),
                  Expanded(
                    child: _buildAnalyticTile(
                      icon: Icons.local_shipping_rounded,
                      title: 'Pending Shipments',
                      value: hub.pendingShipments.toString(),
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  Expanded(
                    child: _buildAnalyticTile(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Inventory Value',
                      value:
                          '₹${hub.inventoryValueInLakhs.toStringAsFixed(1)}L',
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Action button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Connecting to ${hub.hubCity} Central Dispatch Hub...'),
                      backgroundColor: const Color(0xFF0F4C81),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                icon: const Icon(Icons.hub_rounded, color: Colors.white),
                label: const Text(
                  'Access Central Hub Console',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D3B66),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF7F8C8D),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
