import 'package:latlong2/latlong.dart';

enum HubMarkerType {
  warehouse,
  deliveryTruck,
  premiumStore,
}

class StateHub {
  final String stateName;
  final String hubCity;
  final LatLng coordinate;
  final int activeVendors;
  final int pendingShipments;
  final double inventoryValueInLakhs;
  final HubMarkerType markerType;

  const StateHub({
    required this.stateName,
    required this.hubCity,
    required this.coordinate,
    required this.activeVendors,
    required this.pendingShipments,
    required this.inventoryValueInLakhs,
    required this.markerType,
  });
}
