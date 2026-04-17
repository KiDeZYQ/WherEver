import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/reminder.dart';
import '../../services/reminder_service.dart';

/// Page for editing an existing reminder
class EditReminderPage extends StatefulWidget {
  const EditReminderPage({super.key});

  @override
  State<EditReminderPage> createState() => _EditReminderPageState();
}

class _EditReminderPageState extends State<EditReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _fenceRadiusController = TextEditingController(text: '100');

  Reminder? _originalReminder;
  int _triggerType = 1;
  int _repeatType = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationNameController.dispose();
    _fenceRadiusController.dispose();
    super.dispose();
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

    try {
      final reminderService = Get.find<ReminderService>();
      final reminders = await reminderService.getReminders();
      final reminder = reminders.firstWhereOrNull((r) => r.id == reminderId);

      if (reminder == null) {
        setState(() {
          _error = 'Reminder not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _originalReminder = reminder;
        _titleController.text = reminder.title;
        _contentController.text = reminder.content ?? '';
        _locationNameController.text = reminder.locationName ?? '';
        _fenceRadiusController.text = reminder.fenceRadius.toString();
        _triggerType = reminder.triggerType.value;
        _repeatType = reminder.repeatRule?.type.value ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load reminder';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate() || _originalReminder == null) return;

    setState(() => _isSaving = true);

    final updatedReminder = _originalReminder!.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim().isEmpty
          ? null
          : _contentController.text.trim(),
      locationName: _locationNameController.text.trim().isEmpty
          ? null
          : _locationNameController.text.trim(),
      fenceRadius: int.tryParse(_fenceRadiusController.text) ?? 100,
      triggerType: TriggerType.fromInt(_triggerType),
      repeatRule: _repeatType == 0
          ? null
          : RepeatRule(type: RepeatType.fromInt(_repeatType)),
      updatedAt: DateTime.now(),
    );

    final reminderService = Get.find<ReminderService>();
    final success = await reminderService.updateReminder(updatedReminder);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Reminder updated successfully!'
              : 'Failed to update reminder'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Reminder'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _originalReminder == null) {
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

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title field
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title *',
              hintText: 'Enter reminder title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Content field
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Content',
              hintText: 'Enter reminder content (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Location field
          TextFormField(
            controller: _locationNameController,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'Enter location name (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 16),

          // Fence radius
          TextFormField(
            controller: _fenceRadiusController,
            decoration: const InputDecoration(
              labelText: 'Fence Radius (meters)',
              hintText: 'Enter radius in meters',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.radar),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final radius = int.tryParse(value);
                if (radius == null || radius <= 0 || radius > 10000) {
                  return 'Radius must be between 1 and 10000 meters';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Trigger type
          Text(
            'Trigger Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 1,
                label: Text('Arrive'),
                icon: Icon(Icons.login),
              ),
              ButtonSegment(
                value: 2,
                label: Text('Leave'),
                icon: Icon(Icons.logout),
              ),
              ButtonSegment(
                value: 3,
                label: Text('Both'),
                icon: Icon(Icons.swap_horiz),
              ),
            ],
            selected: {_triggerType},
            onSelectionChanged: (Set<int> selection) {
              setState(() => _triggerType = selection.first);
            },
          ),
          const SizedBox(height: 24),

          // Repeat type
          Text(
            'Repeat',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('None'),
              ),
              ButtonSegment(
                value: 1,
                label: Text('Daily'),
              ),
              ButtonSegment(
                value: 2,
                label: Text('Weekly'),
              ),
              ButtonSegment(
                value: 3,
                label: Text('Monthly'),
              ),
            ],
            selected: {_repeatType},
            onSelectionChanged: (Set<int> selection) {
              setState(() => _repeatType = selection.first);
            },
          ),
          const SizedBox(height: 32),

          // Save button
          FilledButton(
            onPressed: _isSaving ? null : _saveReminder,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
