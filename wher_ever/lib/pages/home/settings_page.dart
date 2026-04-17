import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../../pages/auth/auth_controller.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';

/// Page for app settings and user preferences
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final notificationService = Get.find<NotificationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account section
          _buildSectionHeader(context, 'Account'),
          Obx(() {
            final isLoggedIn = Get.find<AuthController>().isLoggedIn.value;
            if (isLoggedIn) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(authService.currentUser?.username ?? 'User'),
                    subtitle: Text(authService.currentUser?.email ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAccountDetails(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Login'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Get.to(() => const LoginPage()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.app_registration),
                    title: const Text('Register'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Get.to(() => const RegisterPage()),
                  ),
                ],
              );
            }
          }),

          const Divider(),

          // Notifications section
          _buildSectionHeader(context, 'Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            subtitle: const Text('Configure notification preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showNotificationSettings(context, notificationService),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Sound'),
            subtitle: const Text('Play sound on notification'),
            value: true,
            onChanged: (value) {
              // TODO: Implement sound preference
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate on notification'),
            value: true,
            onChanged: (value) {
              // TODO: Implement vibration preference
            },
          ),

          const Divider(),

          // Location section
          _buildSectionHeader(context, 'Location'),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Location Permissions'),
            subtitle: const Text('Manage location access'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed('/geofence/status'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.gps_fixed),
            title: const Text('Background Location'),
            subtitle: const Text('Allow location access when app is closed'),
            value: false,
            onChanged: (value) {
              // TODO: Implement background location preference
            },
          ),

          const Divider(),

          // App section
          _buildSectionHeader(context, 'App'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageSelector(context),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeSelector(context),
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Data Export/Import'),
            subtitle: const Text('Backup and restore your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed('/data/export'),
          ),

          const Divider(),

          // About section
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About WherEver'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open terms of service
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open app store
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showAccountDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildDetailRow('User ID', Get.find<AuthService>().currentUser?.id ?? ''),
            _buildDetailRow('Username', Get.find<AuthService>().currentUser?.username ?? ''),
            _buildDetailRow('Email', Get.find<AuthService>().currentUser?.email ?? ''),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Get.find<AuthController>().logout();
              Get.back();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context, NotificationService service) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('Test Notification'),
              subtitle: const Text('Send a test notification'),
              onTap: () {
                service.showReminderNotification(
                  title: 'Test Reminder',
                  body: 'This is a test notification',
                );
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Clear All Notifications'),
              subtitle: const Text('Remove all pending notifications'),
              onTap: () async {
                final navigator = Navigator.of(context);
                await service.cancelAll();
                navigator.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications cleared')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('English'),
              value: 'en',
              groupValue: 'en',
              onChanged: (value) => Navigator.of(context).pop(),
            ),
            RadioListTile(
              title: const Text('简体中文'),
              value: 'zh',
              groupValue: 'en',
              onChanged: (value) => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('System Default'),
              value: 'system',
              groupValue: 'system',
              onChanged: (value) => Navigator.of(context).pop(),
            ),
            RadioListTile(
              title: const Text('Light'),
              value: 'light',
              groupValue: 'system',
              onChanged: (value) => Navigator.of(context).pop(),
            ),
            RadioListTile(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: 'system',
              onChanged: (value) => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'WherEver',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.location_on, size: 48, color: Colors.deepPurple),
      children: [
        const Text(
          'WherEver is a location-based reminder app that helps you remember things based on where you are.',
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2024 WherEver. All rights reserved.',
        ),
      ],
    );
  }
}
