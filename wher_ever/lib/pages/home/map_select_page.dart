import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/location_service.dart';

/// Page for selecting a point on the map
/// Note: This is a placeholder - map SDK (Google Maps or AMap) needs to be integrated
class MapSelectPage extends StatefulWidget {
  const MapSelectPage({super.key});

  @override
  State<MapSelectPage> createState() => _MapSelectPageState();
}

class _MapSelectPageState extends State<MapSelectPage> {
  final _locationService = Get.find<LocationService>();
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() => _isLoading = true);
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _selectedLatitude = position.latitude;
        _selectedLongitude = position.longitude;
        _selectedAddress = 'Current Location';
        _isLoading = false;
      });
    } else if (mounted) {
      // Default to Shanghai if location not available
      setState(() {
        _selectedLatitude = 31.2304;
        _selectedLongitude = 121.4737;
        _selectedAddress = 'Shanghai (default)';
        _isLoading = false;
      });
    }
  }

  void _onMapTap(double lat, double lng) {
    setState(() {
      _selectedLatitude = lat;
      _selectedLongitude = lng;
      _selectedAddress = null; // Would need reverse geocoding
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _selectedLatitude = position.latitude;
        _selectedLongitude = position.longitude;
        _selectedAddress = 'Current Location';
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get current location'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmSelection() {
    if (_selectedLatitude == null || _selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Get.back(result: {
      'latitude': _selectedLatitude,
      'longitude': _selectedLongitude,
      'address': _selectedAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _isLoading ? null : _getCurrentLocation,
            tooltip: 'Go to current location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Map placeholder
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      // Map placeholder - integrate Google Maps or AMap here
                      Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Map Placeholder',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Integrate Google Maps or AMap SDK',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 24),
                              // Demo: tap to select point
                              Text(
                                'Current selection:',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              if (_selectedLatitude != null &&
                                  _selectedLongitude != null)
                                Text(
                                  '${_selectedLatitude!.toStringAsFixed(6)}, '
                                  '${_selectedLongitude!.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => _onMapTap(
                                  _selectedLatitude! + 0.001,
                                  _selectedLongitude! + 0.001,
                                ),
                                child: const Text('Simulate Tap (Demo)'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Selected location marker
                      if (_selectedLatitude != null &&
                          _selectedLongitude != null)
                        Center(
                          child: Icon(
                            Icons.location_pin,
                            size: 48,
                            color: Colors.red.shade600,
                          ),
                        ),
                    ],
                  ),
          ),

          // Bottom panel with selection info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selected Location',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_selectedLatitude != null && _selectedLongitude != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedAddress ??
                                '${_selectedLatitude!.toStringAsFixed(6)}, '
                                    '${_selectedLongitude!.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _confirmSelection,
                      child: const Text('Confirm Selection'),
                    ),
                  ] else
                    Text(
                      'Tap on the map to select a location',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
