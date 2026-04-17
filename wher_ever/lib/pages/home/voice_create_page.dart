import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/speech_recognition_service.dart';
import '../../services/voice_command_parser.dart';
import '../../services/permission_guard.dart';
import '../../services/reminder_service.dart';
import '../../pages/auth/auth_controller.dart';

/// Page for creating reminders via voice command
class VoiceCreatePage extends StatefulWidget {
  const VoiceCreatePage({super.key});

  @override
  State<VoiceCreatePage> createState() => _VoiceCreatePageState();
}

class _VoiceCreatePageState extends State<VoiceCreatePage> {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final VoiceCommandParser _parser = VoiceCommandParser();
  final PermissionGuard _permissionGuard = PermissionGuard();

  bool _isListening = false;
  String _recognizedText = '';
  String _partialText = '';
  VoiceCommandParseResult? _parseResult;
  int _currentReminderCount = 0; // Would come from ReminderService

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speechService.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _startListening() async {
    // Check permission first
    final authController = Get.find<AuthController>();
    final currentCount = authController.isLoggedIn.value ? 0 : _currentReminderCount;

    final permission = _permissionGuard.canCreateReminder(currentCount);
    if (!permission.allowed) {
      await _permissionGuard.showPermissionDialog(context, permission);
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _partialText = '';
      _parseResult = null;
    });

    await _speechService.startListening(
      onResult: (String text) {
        setState(() {
          _recognizedText = text;
          _isListening = false;
          _parseResult = _parser.parse(text);
        });
      },
      onPartialResult: (String text) {
        setState(() {
          _partialText = text;
        });
      },
      onListeningComplete: () {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _createReminder() async {
    if (_parseResult == null) return;

    final reminderService = Get.find<ReminderService>();
    final result = await reminderService.createReminder(
      title: _parseResult!.title,
      content: _parseResult!.content,
      locationName: _parseResult!.locationName,
      latitude: _parseResult!.latitude,
      longitude: _parseResult!.longitude,
      triggerType: _parseResult!.triggerType ?? 1,
      repeatType: _parseResult!.repeatType,
    );

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
        title: const Text('Voice Create'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Microphone button
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.red : Colors.deepPurple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.red : Colors.deepPurple)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status text
              Text(
                _isListening
                    ? 'Listening...'
                    : _recognizedText.isEmpty
                        ? 'Tap to speak'
                        : 'Tap to speak again',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Partial result
              if (_isListening && _partialText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _partialText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),

              // Final result
              if (_recognizedText.isNotEmpty && _parseResult != null) ...[
                const SizedBox(height: 24),
                _buildParseResultCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParseResultCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recognized',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _recognizedText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 24),
            Text(
              'Reminder Details',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Title', _parseResult!.title),
            if (_parseResult!.hasLocation)
              _buildDetailRow('Location', _parseResult!.locationName ?? 'Set'),
            if (_parseResult!.triggerType != null)
              _buildDetailRow('Trigger', _getTriggerLabel(_parseResult!.triggerType!)),
            if (_parseResult!.hasRepeat)
              _buildDetailRow('Repeat', _getRepeatLabel(_parseResult!.repeatType!)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createReminder,
                child: const Text('Create Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTriggerLabel(int value) {
    switch (value) {
      case 1:
        return 'Arrive';
      case 2:
        return 'Leave';
      case 3:
        return 'Both';
      default:
        return 'Unknown';
    }
  }

  String _getRepeatLabel(int value) {
    switch (value) {
      case 1:
        return 'Daily';
      case 2:
        return 'Weekly';
      case 3:
        return 'Monthly';
      case 4:
        return 'Yearly';
      default:
        return 'None';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
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
}
