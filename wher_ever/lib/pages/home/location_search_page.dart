import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/location_service.dart';

/// Page for searching locations
class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final _searchController = TextEditingController();
  final _locationService = Get.find<LocationService>();
  final List<_SearchResult> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  // Mock recent locations for demo
  final List<_SearchResult> _recentLocations = [
    _SearchResult(
      name: 'Home',
      address: '123 Main Street',
      latitude: 31.2304,
      longitude: 121.4737,
    ),
    _SearchResult(
      name: 'Office',
      address: '456 Business Ave',
      latitude: 31.2404,
      longitude: 121.4837,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Simulate search delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock search results - in real app, call geocoding API
    setState(() {
      _results.clear();
      _results.addAll([
        _SearchResult(
          name: query,
          address: 'Result 1 for "$query"',
          latitude: 31.2304,
          longitude: 121.4737,
        ),
        _SearchResult(
          name: '$query Branch',
          address: 'Result 2 for "$query"',
          latitude: 31.2404,
          longitude: 121.4837,
        ),
      ]);
      _isLoading = false;
    });
  }

  void _selectLocation(_SearchResult result) {
    Get.back(result: {
      'name': result.name,
      'address': result.address,
      'latitude': result.latitude,
      'longitude': result.longitude,
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      final result = _SearchResult(
        name: 'Current Location',
        address: '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}',
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _selectLocation(result);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _isLoading ? null : _getCurrentLocation,
            tooltip: 'Use current location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results.clear();
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Results
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      // Show recent locations
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Recent Locations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          ..._recentLocations.map((location) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(location.name),
                subtitle: Text(location.address),
                onTap: () => _selectLocation(location),
              )),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Tip: Use the location button in the top right to get your current location',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(result.name),
          subtitle: Text(result.address),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _selectLocation(result),
        );
      },
    );
  }
}

class _SearchResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  _SearchResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}
