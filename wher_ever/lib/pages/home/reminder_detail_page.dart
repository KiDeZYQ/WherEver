import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/reminder.dart';
import '../../services/reminder_service.dart';

/// Page for displaying reminder details
class ReminderDetailPage extends StatefulWidget {
  const ReminderDetailPage({super.key});

  @override
  State<ReminderDetailPage> createState() => _ReminderDetailPageState();
}

class _ReminderDetailPageState extends State<ReminderDetailPage> {
  final ReminderService _reminderService = Get.find<ReminderService>();
  Reminder? _reminder;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final reminderId = Get.parameters['id'];
    if (reminderId == null) {
      setState(() {
        _error = 'Invalid reminder ID';
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reminders = await _reminderService.getReminders();
      final reminder = reminders.firstWhereOrNull((r) => r.id == reminderId);
      setState(() {
        _reminder = reminder;
        _isLoading = false;
        if (reminder == null) {
          _error = 'Reminder not found';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load reminder';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus() async {
    if (_reminder == null) return;

    final updatedReminder = _reminder!.copyWith(
      status: _reminder!.status == ReminderStatus.enabled
          ? ReminderStatus.disabled
          : ReminderStatus.enabled,
      updatedAt: DateTime.now(),
    );

    final success = await _reminderService.updateReminder(updatedReminder);
    if (success && mounted) {
      setState(() => _reminder = updatedReminder);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updatedReminder.status == ReminderStatus.enabled
              ? 'Reminder enabled'
              : 'Reminder disabled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _deleteReminder() async {
    if (_reminder == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${_reminder!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _reminderService.deleteReminder(_reminder!.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder deleted'),
            backgroundColor: Colors.orange,
          ),
        );
        Get.back();
      }
    }
  }

  String _getTriggerLabel(TriggerType type) {
    switch (type) {
      case TriggerType.arrive:
        return 'Arrive';
      case TriggerType.leave:
        return 'Leave';
      case TriggerType.both:
        return 'Both';
    }
  }

  String _getRepeatLabel(RepeatType? type) {
    if (type == null || type == RepeatType.none) return 'No repeat';
    switch (type) {
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.yearly:
        return 'Yearly';
      default:
        return 'No repeat';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Detail'),
        actions: [
          if (_reminder != null) ...[
            IconButton(
              icon: Icon(
                _reminder!.status == ReminderStatus.enabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
              ),
              onPressed: _toggleStatus,
              tooltip: _reminder!.status == ReminderStatus.enabled
                  ? 'Disable reminder'
                  : 'Enable reminder',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteReminder,
              tooltip: 'Delete reminder',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _reminder == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(_error ?? 'Reminder not found',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            color: _reminder!.status == ReminderStatus.enabled
                ? Colors.green.shade50
                : Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _reminder!.status == ReminderStatus.enabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: _reminder!.status == ReminderStatus.enabled
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _reminder!.status == ReminderStatus.enabled
                              ? 'Active'
                              : 'Disabled',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _reminder!.status == ReminderStatus.enabled
                              ? 'You will receive notifications'
                              : 'Notifications are paused',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _reminder!.status == ReminderStatus.enabled,
                    onChanged: (_) => _toggleStatus(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _reminder!.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Content
          if (_reminder!.content != null && _reminder!.content!.isNotEmpty) ...[
            Text(
              _reminder!.content!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],

          // Details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    Icons.login,
                    'Trigger',
                    _getTriggerLabel(_reminder!.triggerType),
                  ),
                  _buildDetailRow(
                    Icons.location_on,
                    'Location',
                    _reminder!.locationName ?? 'Not set',
                  ),
                  if (_reminder!.hasLocation) ...[
                    _buildDetailRow(
                      Icons.my_location,
                      'Coordinates',
                      '${_reminder!.latitude!.toStringAsFixed(6)}, '
                          '${_reminder!.longitude!.toStringAsFixed(6)}',
                    ),
                    _buildDetailRow(
                      Icons.radar,
                      'Fence Radius',
                      '${_reminder!.fenceRadius} meters',
                    ),
                  ],
                  _buildDetailRow(
                    Icons.repeat,
                    'Repeat',
                    _getRepeatLabel(_reminder!.repeatRule?.type),
                  ),
                  _buildDetailRow(
                    Icons.access_time,
                    'Created',
                    _formatDateTime(_reminder!.createdAt),
                  ),
                  _buildDetailRow(
                    Icons.update,
                    'Updated',
                    _formatDateTime(_reminder!.updatedAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed('/reminder/edit/${_reminder!.id}'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _deleteReminder,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
