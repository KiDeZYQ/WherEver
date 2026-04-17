import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/reminder_service.dart';
import '../../services/permission_guard.dart';
import '../auth/auth_controller.dart';

/// Page for manually creating reminders
class ManualCreatePage extends StatefulWidget {
  const ManualCreatePage({super.key});

  @override
  State<ManualCreatePage> createState() => _ManualCreatePageState();
}

class _ManualCreatePageState extends State<ManualCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _fenceRadiusController = TextEditingController(text: '100');

  int _triggerType = 1; // 1=arrive, 2=leave, 3=both
  int _repeatType = 0; // 0=none, 1=daily, 2=weekly, 3=monthly, 4=yearly
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationNameController.dispose();
    _fenceRadiusController.dispose();
    super.dispose();
  }

  Future<void> _createReminder() async {
    if (!_formKey.currentState!.validate()) return;

    final permissionGuard = PermissionGuard();
    final authController = Get.find<AuthController>();
    final currentCount = authController.isLoggedIn.value ? 0 : 0;

    final permission = permissionGuard.canCreateReminder(currentCount);
    if (!permission.allowed) {
      await permissionGuard.showPermissionDialog(context, permission);
      return;
    }

    setState(() => _isLoading = true);

    final reminderService = Get.find<ReminderService>();
    final result = await reminderService.createReminder(
      title: _titleController.text.trim(),
      content: _contentController.text.trim().isEmpty
          ? null
          : _contentController.text.trim(),
      locationName: _locationNameController.text.trim().isEmpty
          ? null
          : _locationNameController.text.trim(),
      fenceRadius: int.tryParse(_fenceRadiusController.text) ?? 100,
      triggerType: _triggerType,
      repeatType: _repeatType == 0 ? null : _repeatType,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result != null
              ? 'Reminder created successfully!'
              : 'Failed to create reminder'),
          backgroundColor: result != null ? Colors.green : Colors.red,
        ),
      );
      if (result != null) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reminder'),
      ),
      body: Form(
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

            // Submit button
            FilledButton(
              onPressed: _isLoading ? null : _createReminder,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
