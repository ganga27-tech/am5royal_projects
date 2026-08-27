import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';

class LocationDetails {
  final double latitude;
  final double longitude;
  final String? address;
  final String? street;
  final String? city;
  final String? district;
  final String? state;
  final String? pincode;

  LocationDetails({
    required this.latitude,
    required this.longitude,
    this.address,
    this.street,
    this.city,
    this.district,
    this.state,
    this.pincode,
  });
}

class LocationSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;

  LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

class LocationPickerMapWidget extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final Function(LocationDetails details) onLocationSelected;
  final VoidCallback? onInteractionStart;

  const LocationPickerMapWidget({
    super.key,
    this.initialLatitude = 17.3850, // Default Hyderabad latitude
    this.initialLongitude = 78.4867, // Default Hyderabad longitude
    this.initialZoom = 15.0,
    required this.onLocationSelected,
    this.onInteractionStart,
  });

  @override
  State<LocationPickerMapWidget> createState() =>
      LocationPickerMapWidgetState();
}

class LocationPickerMapWidgetState extends State<LocationPickerMapWidget> {
  GoogleMapController? _googleMapController;
  late LatLng _currentCenter;
  bool _isGeocoding = false;
  bool _isLocatingUser = false;
  Timer? _debounceTimer;

  // Location Search State
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<LocationSearchResult> _searchResults = [];
  Timer? _searchDebounceTimer;

  static const String _googleApiKey = 'AIzaSyA95rPQiB5I9a4FIGT2RfrcVWsmpudfuBM';

  final Dio _dio = Dio(
    BaseOptions(
      headers: {'User-Agent': 'AM5RoyalVendorApp/1.0 (contact@am5royal.com)'},
      connectTimeout: const Duration(seconds: 6),
      receiveTimeout: const Duration(seconds: 6),
    ),
  );

  @override
  void initState() {
    super.initState();
    _currentCenter = LatLng(widget.initialLatitude, widget.initialLongitude);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onMapSettled(_currentCenter);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String value) {
    _searchDebounceTimer?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    _searchDebounceTimer = Timer(const Duration(milliseconds: 450), () {
      _searchLocation(value);
    });
  }

  Future<void> _searchLocation(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSearching = true;
      });
    }

    final List<LocationSearchResult> results = [];

    // First try Google Geocoding API for exact results
    try {
      final googleUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(cleanQuery)}&key=$_googleApiKey';
      final response = await _dio.get(googleUrl);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == 'OK' && data['results'] != null) {
          final list = data['results'] as List<dynamic>;
          for (final item in list) {
            final formatted = item['formatted_address'] as String?;
            final location = item['geometry']?['location'];
            if (formatted != null && location != null) {
              final lat = (location['lat'] as num?)?.toDouble();
              final lng = (location['lng'] as num?)?.toDouble();
              if (lat != null && lng != null) {
                results.add(LocationSearchResult(
                  displayName: formatted,
                  latitude: lat,
                  longitude: lng,
                ));
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Google forward search error: $e');
    }

    // Fallback: OpenStreetMap Nominatim search API if Google yielded no results
    if (results.isEmpty) {
      try {
        final response = await _dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'format': 'json',
            'q': cleanQuery,
            'addressdetails': 1,
            'limit': 5,
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          final list = response.data as List<dynamic>;
          for (final item in list) {
            final displayName = item['display_name'] as String?;
            final latStr = item['lat'] as String?;
            final lonStr = item['lon'] as String?;
            if (displayName != null && latStr != null && lonStr != null) {
              final lat = double.tryParse(latStr);
              final lng = double.tryParse(lonStr);
              if (lat != null && lng != null) {
                results.add(LocationSearchResult(
                  displayName: displayName,
                  latitude: lat,
                  longitude: lng,
                ));
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Nominatim forward search error: $e');
      }
    }

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(LocationSearchResult result) {
    _searchController.text = result.displayName;
    _searchFocusNode.unfocus();
    setState(() {
      _searchResults = [];
    });
    moveToLocation(LatLng(result.latitude, result.longitude));
  }

  /// Programmatically move map center and trigger geocoding
  void moveToLocation(LatLng point,
      {double zoom = 16.0, bool triggerGeocode = true}) {
    setState(() {
      _currentCenter = point;
    });
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: zoom),
      ),
    );
    if (triggerGeocode) {
      _onMapSettled(point);
    }
  }

  Future<void> _onMapSettled(LatLng point) async {
    if (!mounted) return;
    setState(() {
      _isGeocoding = true;
    });

    String? address;
    String? street;
    String? city;
    String? district;
    String? state;
    String? pincode;

    // First attempt: Google Maps Reverse Geocoding API for ultra accuracy
    try {
      final googleUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${point.latitude},${point.longitude}&key=$_googleApiKey';
      final googleRes = await _dio.get(googleUrl);
      if (googleRes.statusCode == 200 && googleRes.data != null) {
        final data = googleRes.data;
        if (data['status'] == 'OK' &&
            data['results'] != null &&
            (data['results'] as List).isNotEmpty) {
          final firstResult = data['results'][0];
          address = firstResult['formatted_address'] as String?;
          final components =
              firstResult['address_components'] as List<dynamic>?;
          if (components != null) {
            final streetParts = <String>[];
            for (final comp in components) {
              final types =
                  (comp['types'] as List<dynamic>?)?.cast<String>() ?? [];
              final longName = comp['long_name'] as String?;
              if (longName != null && longName.isNotEmpty) {
                if (types.contains('route') ||
                    types.contains('sublocality_level_1') ||
                    types.contains('sublocality') ||
                    types.contains('neighborhood')) {
                  if (!streetParts.contains(longName)) {
                    streetParts.add(longName);
                  }
                }
                if (types.contains('locality')) {
                  city = longName;
                } else if (city == null &&
                    (types.contains('administrative_area_level_3') ||
                        types.contains('sublocality_level_1') ||
                        types.contains('sublocality'))) {
                  city = longName;
                }
                if (types.contains('administrative_area_level_2')) {
                  district = longName;
                } else if (district == null && types.contains('administrative_area_level_3')) {
                  district = longName;
                }
                if (types.contains('administrative_area_level_1')) {
                  state = longName;
                }
                if (types.contains('postal_code')) {
                  pincode = longName;
                }
              }
            }
            if (streetParts.isNotEmpty) {
              street = streetParts.join(', ');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Google Geocoding API error: $e');
    }

    // Fallback: OpenStreetMap Nominatim API if Google Geocoding yielded incomplete city/district/state/address
    if (city == null || district == null || state == null || address == null) {
      try {
        final response = await _dio.get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'format': 'json',
            'lat': point.latitude,
            'lon': point.longitude,
            'addressdetails': 1,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          address ??= data['display_name'] as String?;
          final addrObj = data['address'] as Map<String, dynamic>?;
          if (addrObj != null) {
            street ??= addrObj['road'] ??
                addrObj['suburb'] ??
                addrObj['neighbourhood'] ??
                addrObj['residential'];
            city ??= addrObj['city'] ??
                addrObj['town'] ??
                addrObj['village'] ??
                addrObj['suburb'] ??
                addrObj['city_district'] ??
                addrObj['municipality'] ??
                addrObj['county'] ??
                addrObj['state_district'];
            district ??= addrObj['county'] ??
                addrObj['state_district'] ??
                addrObj['district'] ??
                addrObj['city_district'];
            state ??= addrObj['state'];
            pincode ??= addrObj['postcode'];
          }
        }
      } catch (e) {
        debugPrint('Nominatim Geocoding fallback error: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isGeocoding = false;
      });
      widget.onLocationSelected(LocationDetails(
        latitude: point.latitude,
        longitude: point.longitude,
        address: address,
        street: street,
        city: city,
        district: district,
        state: state,
        pincode: pincode,
      ));
    }
  }

  Future<void> _moveToUserCurrentLocation() async {
    setState(() {
      _isLocatingUser = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Please enable location services on your device.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Location permissions are permanently denied in settings.')),
          );
        }
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final userLatLng = LatLng(pos.latitude, pos.longitude);
      _searchController.clear();
      setState(() {
        _searchResults = [];
      });
      moveToLocation(userLatLng, zoom: 16.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocatingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Location Search Field above map container
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchTextChanged,
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                _searchLocation(val);
              }
            },
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search location to move map pin...',
              hintStyle: GoogleFonts.outfit(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? AppColors.accentLight : AppColors.primary,
                size: 20,
              ),
              suffixIcon: _isSearching
                  ? const UnconstrainedBox(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (_searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                      : null),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),

        // Search Results Dropdown List
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _searchResults.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? Colors.white12 : Colors.black12,
              ),
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: isDark ? AppColors.accentLight : AppColors.primary,
                  ),
                  title: Text(
                    item.displayName,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _selectSearchResult(item),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 10),

        // Map Container
        Container(
          height: 250,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentCenter,
                  zoom: widget.initialZoom,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _googleMapController = controller;
                },
                onCameraMove: (CameraPosition position) {
                  _currentCenter = position.target;
                  widget.onInteractionStart?.call();
                },
                onCameraIdle: () {
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                    _onMapSettled(_currentCenter);
                  });
                },
                onTap: (LatLng point) {
                  moveToLocation(point);
                },
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
              ),

              // Fixed Center Pin Overlay (IgnorePointer so drag touches reach GoogleMap)
              IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 10,
                          color: AppColors.primary,
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Top Info Header: Coordinates & Reverse Geocode Status
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: IgnorePointer(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black87 : Colors.white)
                          .withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map_rounded,
                          size: 14,
                          color:
                              isDark ? AppColors.accentLight : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${_currentCenter.latitude.toStringAsFixed(5)}, ${_currentCenter.longitude.toStringAsFixed(5)}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isGeocoding) ...[
                          const SizedBox(width: 6),
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.8),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Instruction Badge
              Positioned(
                bottom: 10,
                left: 10,
                child: IgnorePointer(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black87 : Colors.white)
                          .withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Move Google Map pin to select exact location',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Action Button for Current GPS Location
              Positioned(
                bottom: 10,
                right: 10,
                child: Material(
                  color: Colors.transparent,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _isLocatingUser ? null : _moveToUserCurrentLocation,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLocatingUser
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.gps_fixed_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
