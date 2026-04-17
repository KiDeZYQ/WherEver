import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/geofence_service.dart';
import '../../services/permission_guard.dart';

/// Page for monitoring geofence status and managing active monitors
class GeofenceStatusPage extends StatefulWidget {
  const GeofenceStatusPage({super.key});

  @override
  State<GeofenceStatusPage> createState() => _GeofenceStatusPageState();
}

class _GeofenceStatusPageState extends State<GeofenceStatusPage> {
  final GeofenceService _geofenceService = Get.find<GeofenceService>();
  final PermissionGuard _permissionGuard = PermissionGuard();
  bool _isLoading = false;
  String? _locationStatus;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final permission = await _permissionGuard.checkLocationPermission();
    setState(() {
      _locationStatus = _getPermissionStatus(permission);
    });
  }

  String _getPermissionStatus(dynamic permission) {
    if (permission == null) return 'Unknown';
    // LocationPermission is an enum-like
    final permStr = permission.toString();
    if (permStr.contains('whileInUse')) return 'Granted (While In Use)';
    if (permStr.contains('always')) return 'Granted (Always)';
    if (permStr.contains('denied')) return 'Denied';
    if (permStr.contains('deniedForever')) return 'Denied Forever';
    return 'Unknown';
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);
    final granted = await _permissionGuard.requestLocationPermission();
    await _checkLocationPermission();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(granted ? 'Location permission granted' : 'Location permission denied'),
          backgroundColor: granted ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence Status'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Location permission card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _locationStatus?.contains('Granted') == true
                            ? Icons.location_on
                            : Icons.location_off,
                        color: _locationStatus?.contains('Granted') == true
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location Permission',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _locationStatus ?? 'Checking...',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_locationStatus?.contains('Granted') != true) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _requestLocationPermission,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Grant Permission'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Active monitors
          Text(
            'Active Geofence Monitors',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Obx(() {
            final count = _geofenceService.monitoredCount;
            if (count == 0) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.location_searching,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No active geofence monitors',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a reminder with location to start monitoring',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: Colors.green.shade400),
                    const SizedBox(height: 16),
                    Text(
                      '$count geofence monitor(s) active',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You will receive notifications when you enter or leave monitored locations',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Info section
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'How Geofencing Works',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue.shade700,
                            ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInfoRow(Icons.login, 'Arrive', 'Notification when you reach a location'),
                  _buildInfoRow(Icons.logout, 'Leave', 'Notification when you depart a location'),
                  _buildInfoRow(Icons.radar, 'Fence Radius', 'Area around a location that triggers notifications'),
                  _buildInfoRow(Icons.battery_std, 'Battery', 'Optimized for minimal battery usage'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
