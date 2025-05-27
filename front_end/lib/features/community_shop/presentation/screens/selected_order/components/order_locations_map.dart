import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

class OrderLocationsMap extends StatefulWidget {
  final CommunityOrder order;
  final double height;

  const OrderLocationsMap({
    Key? key,
    required this.order,
    this.height = 250,
  }) : super(key: key);

  @override
  State<OrderLocationsMap> createState() => _OrderLocationsMapState();
}

class _OrderLocationsMapState extends State<OrderLocationsMap> {
  bool _isLoading = true;
  String _errorMessage = '';

  // Store information about locations
  LatLng _storeLocation = const LatLng(48.8566, 2.3522); // Paris as default
  LatLng _customerLocation = const LatLng(48.8656, 2.3622); // Slightly offset
  LatLng _userLocation = const LatLng(48.8466, 2.3422); // Slightly offset

  // Selected marker info
  bool _showInfoWindow = false;
  String _infoWindowTitle = '';
  String _infoWindowAddress = '';
  final GlobalKey _mapKey = GlobalKey();

  // Map controller
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Timeout for loading
  Timer? _loadingTimeout;

  @override
  void initState() {
    super.initState();
    _loadLocations();

    // Set a timeout to prevent infinite loading state
    _loadingTimeout = Timer(const Duration(seconds: 15), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Temps d\'attente dépassé pour le chargement de la carte';
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      debugPrint('OrderLocationsMap: Starting to load locations');

      // Get coordinates from addresses
      debugPrint(
          'OrderLocationsMap: Store address: ${widget.order.storeAddress}');
      LatLng? storeCoordinates =
          await _getCoordinatesFromAddress(widget.order.storeAddress);

      // Fallback to default coordinates if geocoding fails
      if (storeCoordinates == null) {
        storeCoordinates = const LatLng(48.8566, 2.3522);
      }
      _storeLocation = storeCoordinates;

      debugPrint(
          'OrderLocationsMap: Customer address: ${widget.order.deliveryAddress}');
      LatLng? customerCoordinates =
          await _getCoordinatesFromAddress(widget.order.deliveryAddress);

      // Fallback to default coordinates if geocoding fails
      if (customerCoordinates == null) {
        customerCoordinates = LatLng(
            _storeLocation.latitude + 0.01, _storeLocation.longitude + 0.01);
      }
      _customerLocation = customerCoordinates;

      // If store and customer are at the same location, slightly offset the customer marker
      if (_customerLocation.latitude == _storeLocation.latitude &&
          _customerLocation.longitude == _storeLocation.longitude) {
        _customerLocation = LatLng(_storeLocation.latitude + 0.0005,
            _storeLocation.longitude + 0.0005);
      }

      // Set user's location (simulated)
      _userLocation = LatLng(
          _storeLocation.latitude - 0.005, _storeLocation.longitude - 0.005);

      // Clear existing markers and polylines
      _markers.clear();
      _polylines.clear();

      // If map is already created, update it
      if (_mapController != null) {
        _addMarkers();
        _addRoutes();
        _fitBounds();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('OrderLocationsMap: Error loading map: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger la carte: $e';
      });
    }
  }

  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      debugPrint('OrderLocationsMap: Geocoding address: $address');

      // Try to add country if not present to improve geocoding results
      if (!address.toLowerCase().contains('france')) {
        address = '$address, France';
        debugPrint('OrderLocationsMap: Added country to address: $address');
      }

      final locations = await locationFromAddress(address);
      debugPrint('OrderLocationsMap: Geocoding result: $locations');

      if (locations.isNotEmpty) {
        debugPrint(
            'OrderLocationsMap: Found coordinates: ${locations.first.latitude}, ${locations.first.longitude}');
        return LatLng(locations.first.latitude, locations.first.longitude);
      }

      debugPrint('OrderLocationsMap: No locations found for address: $address');
      return null;
    } catch (e) {
      debugPrint(
          'OrderLocationsMap: Error getting coordinates for address: $address');
      debugPrint('OrderLocationsMap: Error details: $e');
      return null;
    }
  }

  // Add markers for store, customer, and user locations
  void _addMarkers() {
    debugPrint('OrderLocationsMap: Adding markers');
    debugPrint(
        'OrderLocationsMap: Store location: ${_storeLocation.latitude}, ${_storeLocation.longitude}');
    debugPrint(
        'OrderLocationsMap: Customer location: ${_customerLocation.latitude}, ${_customerLocation.longitude}');
    debugPrint(
        'OrderLocationsMap: User location: ${_userLocation.latitude}, ${_userLocation.longitude}');

    // Clear existing markers
    _markers.clear();

    // Store marker (blue)
    _markers.add(
      Marker(
        markerId: const MarkerId('store'),
        position: _storeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () {
          _showCustomInfoWindow(
            position: _storeLocation,
            title: widget.order.storeName,
            address: widget.order.storeAddress,
          );
          // Prevent map from moving when marker is tapped
          if (_mapController != null) {
            _mapController!
                .animateCamera(CameraUpdate.newLatLngBounds(_getBounds(), 50));
          }
        },
      ),
    );

    // Customer marker (green)
    _markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: _customerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () {
          _showCustomInfoWindow(
            position: _customerLocation,
            title: widget.order.customerName,
            address: widget.order.deliveryAddress,
          );
          // Prevent map from moving when marker is tapped
          if (_mapController != null) {
            _mapController!
                .animateCamera(CameraUpdate.newLatLngBounds(_getBounds(), 50));
          }
        },
      ),
    );

    // User marker (red)
    _markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: _userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          _showCustomInfoWindow(
            position: _userLocation,
            title: 'Vous',
            address: 'Votre position actuelle',
          );
          // Prevent map from moving when marker is tapped
          if (_mapController != null) {
            _mapController!
                .animateCamera(CameraUpdate.newLatLngBounds(_getBounds(), 50));
          }
        },
      ),
    );
  }

  // Show custom info window with marker information
  void _showCustomInfoWindow({
    required LatLng position,
    required String title,
    required String address,
  }) {
    setState(() {
      _showInfoWindow = true;
      _infoWindowTitle = title;
      _infoWindowAddress = address;
    });
  }

  // Copy address to clipboard
  void _copyAddressToClipboard() {
    Clipboard.setData(ClipboardData(text: _infoWindowAddress)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adresse copiée: $_infoWindowAddress')),
      );
    });
  }

  // Open full-screen map view
  void _openFullScreenMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMapView(
          storeLocation: _storeLocation,
          customerLocation: _customerLocation,
          userLocation: _userLocation,
          order: widget.order,
        ),
      ),
    );
  }

  // Calculate bounds to fit all markers
  LatLngBounds _getBounds() {
    return LatLngBounds(
      southwest: LatLng(
        [
          _storeLocation.latitude,
          _customerLocation.latitude,
          _userLocation.latitude
        ].reduce((value, element) => value < element ? value : element),
        [
          _storeLocation.longitude,
          _customerLocation.longitude,
          _userLocation.longitude
        ].reduce((value, element) => value < element ? value : element),
      ),
      northeast: LatLng(
        [
          _storeLocation.latitude,
          _customerLocation.latitude,
          _userLocation.latitude
        ].reduce((value, element) => value > element ? value : element),
        [
          _storeLocation.longitude,
          _customerLocation.longitude,
          _userLocation.longitude
        ].reduce((value, element) => value > element ? value : element),
      ),
    );
  }

  // Add route lines between locations
  void _addRoutes() {
    // Store to customer route (blue)
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('store_to_customer'),
        color: Colors.blue,
        width: 4,
        points: [_storeLocation, _customerLocation],
        patterns: [PatternItem.dash(15), PatternItem.gap(10)],
      ),
    );

    // User to store route (green)
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('user_to_store'),
        color: Colors.green,
        width: 4,
        points: [_userLocation, _storeLocation],
        patterns: [PatternItem.dash(15), PatternItem.gap(10)],
      ),
    );
  }

  // Fit map to show all markers
  void _fitBounds() {
    if (_mapController == null) return;

    final bounds = _getBounds();
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  // Build a legend item with a colored circle and label
  Widget _buildLegendItem(double hue, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Carte des emplacements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Show loading indicator or error message if needed
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (_errorMessage.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadLocations,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Map view
                  GoogleMap(
                    key: _mapKey,
                    initialCameraPosition: CameraPosition(
                      target: _storeLocation,
                      zoom: 14,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    mapType: MapType.normal,
                    myLocationEnabled: false,
                    compassEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    liteModeEnabled: false,
                    // We'll disable map movement through other settings instead of map style
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        _mapController = controller;
                      });
                      _addMarkers();
                      _addRoutes();
                      _fitBounds();
                    },
                    onTap: (_) {
                      setState(() {
                        _showInfoWindow = false;
                      });
                    },
                  ),

                // Custom info window
                if (_showInfoWindow)
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _infoWindowTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _infoWindowAddress,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                tooltip: 'Copier l\'adresse',
                                onPressed: _copyAddressToClipboard,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Fullscreen button
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen),
                      tooltip: 'Agrandir la carte',
                      onPressed: _openFullScreenMap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(BitmapDescriptor.hueBlue, 'Magasin'),
            const SizedBox(width: 16),
            _buildLegendItem(BitmapDescriptor.hueGreen, 'Client'),
            const SizedBox(width: 16),
            _buildLegendItem(BitmapDescriptor.hueRed, 'Vous'),
          ],
        ),
      ],
    );
  }
}

// Full-screen map view as a separate widget
class FullScreenMapView extends StatefulWidget {
  final LatLng storeLocation;
  final LatLng customerLocation;
  final LatLng userLocation;
  final CommunityOrder order;

  const FullScreenMapView({
    Key? key,
    required this.storeLocation,
    required this.customerLocation,
    required this.userLocation,
    required this.order,
  }) : super(key: key);

  @override
  State<FullScreenMapView> createState() => _FullScreenMapViewState();
}

class _FullScreenMapViewState extends State<FullScreenMapView> {
  GoogleMapController? _mapController;
  bool _showInfoWindow = false;
  String _infoWindowTitle = '';
  String _infoWindowAddress = '';
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initMarkers();
    _addRoutes();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _initMarkers() {
    // Create new markers with custom tap handlers for the full-screen view

    // Store marker (blue)
    _markers.add(
      Marker(
        markerId: const MarkerId('store'),
        position: widget.storeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () {
          _showCustomInfoWindow(
            title: widget.order.storeName,
            address: widget.order.storeAddress,
          );
        },
      ),
    );

    // Customer marker (green)
    _markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: widget.customerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () {
          _showCustomInfoWindow(
            title: widget.order.customerName,
            address: widget.order.deliveryAddress,
          );
        },
      ),
    );

    // User marker (red)
    _markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: widget.userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          _showCustomInfoWindow(
            title: 'Vous',
            address: 'Votre position actuelle',
          );
        },
      ),
    );
  }

  // Add route lines between locations
  void _addRoutes() {
    // Store to customer route (blue)
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('store_to_customer'),
        color: Colors.blue,
        width: 4,
        points: [widget.storeLocation, widget.customerLocation],
        patterns: [PatternItem.dash(15), PatternItem.gap(10)],
      ),
    );

    // User to store route (green)
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('user_to_store'),
        color: Colors.green,
        width: 4,
        points: [widget.userLocation, widget.storeLocation],
        patterns: [PatternItem.dash(15), PatternItem.gap(10)],
      ),
    );
  }

  // Show custom info window with copy functionality
  void _showCustomInfoWindow({required String title, required String address}) {
    setState(() {
      _showInfoWindow = true;
      _infoWindowTitle = title;
      _infoWindowAddress = address;
    });
  }

  // Copy address to clipboard
  void _copyAddressToClipboard() {
    Clipboard.setData(ClipboardData(text: _infoWindowAddress)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adresse copiée: $_infoWindowAddress')),
      );
    });
  }

  // Get bounds for all markers to fit the map view
  LatLngBounds _getBounds() {
    return LatLngBounds(
      southwest: LatLng(
        [
          widget.storeLocation.latitude,
          widget.customerLocation.latitude,
          widget.userLocation.latitude
        ].reduce((value, element) => value < element ? value : element),
        [
          widget.storeLocation.longitude,
          widget.customerLocation.longitude,
          widget.userLocation.longitude
        ].reduce((value, element) => value < element ? value : element),
      ),
      northeast: LatLng(
        [
          widget.storeLocation.latitude,
          widget.customerLocation.latitude,
          widget.userLocation.latitude
        ].reduce((value, element) => value > element ? value : element),
        [
          widget.storeLocation.longitude,
          widget.customerLocation.longitude,
          widget.userLocation.longitude
        ].reduce((value, element) => value > element ? value : element),
      ),
    );
  }

  Widget _buildLegendItem(double hue, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte détaillée'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          // Full-screen map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.storeLocation,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            myLocationEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _mapController = controller;
              });

              // Fit all markers on the map
              controller.animateCamera(
                CameraUpdate.newLatLngBounds(_getBounds(), 50),
              );
            },
            onTap: (_) {
              setState(() {
                _showInfoWindow = false;
              });
            },
          ),

          // Custom info window
          if (_showInfoWindow)
            Positioned(
              left: 20,
              right: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _infoWindowTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _infoWindowAddress,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'Copier l\'adresse',
                          onPressed: _copyAddressToClipboard,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Legend at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(BitmapDescriptor.hueBlue, 'Magasin'),
                  _buildLegendItem(BitmapDescriptor.hueGreen, 'Client'),
                  _buildLegendItem(BitmapDescriptor.hueRed, 'Vous'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
