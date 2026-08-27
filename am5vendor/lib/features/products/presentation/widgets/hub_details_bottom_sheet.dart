import 'package:flutter/material.dart';
import '../../data/models/state_hub_model.dart';

class HubDetailsBottomSheet extends StatelessWidget {
  final StateHub hub;

  const HubDetailsBottomSheet({
    super.key,
    required this.hub,
  });

  static void show(BuildContext context, StateHub hub) {
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
        return HubDetailsBottomSheet(hub: hub);
      },
    );
  }

  Color _getMarkerColor(HubMarkerType type) {
    switch (type) {
      case HubMarkerType.premiumStore:
        return const Color(0xFF10B981); // Emerald
      case HubMarkerType.warehouse:
        return const Color(0xFF0F4C81); // Indigo Royal
      case HubMarkerType.deliveryTruck:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  IconData _getIconForType(HubMarkerType type) {
    switch (type) {
      case HubMarkerType.premiumStore:
        return Icons.storefront_rounded;
      case HubMarkerType.warehouse:
        return Icons.warehouse_rounded;
      case HubMarkerType.deliveryTruck:
        return Icons.local_shipping_rounded;
    }
  }

  Widget _getMarkerIconBadge(HubMarkerType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getMarkerColor(type).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconForType(type), color: _getMarkerColor(type), size: 16),
          const SizedBox(width: 6),
          Text(
            type.name.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _getMarkerColor(type),
            ),
          ),
        ],
      ),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D3B66),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF7F8C8D),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F4C81),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Primary Hub: ${hub.hubCity}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              _getMarkerIconBadge(hub.markerType),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // Analytics details in a beautiful row
          Row(
            children: [
              Expanded(
                child: _buildAnalyticTile(
                  icon: Icons.people_rounded,
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
                  value: '₹${hub.inventoryValueInLakhs.toStringAsFixed(1)}L',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

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
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C81),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
