import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'services/auth_service.dart';
import 'pages/auth/auth_controller.dart';
import 'pages/home/voice_create_page.dart';
import 'pages/home/manual_create_page.dart';
import 'pages/home/reminder_list_page.dart';
import 'pages/home/geofence_status_page.dart';
import 'pages/home/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('WherEver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Get.to(() => const ReminderListPage()),
            tooltip: 'My Reminders',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsPage()),
            tooltip: 'Settings',
          ),
          Obx(() => authController.isLoggedIn.value
              ? PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await authController.logout();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(authController.currentUser.value?.username ?? 'User'),
                        subtitle: Text(authController.currentUser.value?.email ?? ''),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.to(() => const LoginPage());
                      },
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const RegisterPage());
                      },
                      child: const Text('Register'),
                    ),
                  ],
                )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero section
            Center(
              child: Column(
                children: [
                  const Icon(Icons.location_on, size: 80, color: Colors.deepPurple),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to WherEver',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (authController.isLoggedIn.value) {
                      return Column(
                        children: [
                          Text(
                            'Logged in as: ${authController.currentUser.value?.username ?? "User"}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (authController.currentUser.value?.isPremium ?? false)
                            const Chip(
                              label: Text('Premium'),
                              backgroundColor: Colors.amber,
                            ),
                        ],
                      );
                    } else if (authService.isGuest) {
                      return Column(
                        children: [
                          Text(
                            'Guest Mode - ${authService.getRemainingReminderSlots()} reminders remaining',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            authService.getSessionExpiryInfo() ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Get.to(() => const RegisterPage());
                            },
                            child: const Text('Create Account'),
                          ),
                        ],
                      );
                    } else {
                      return Text(
                        'Please login to continue',
                        style: Theme.of(context).textTheme.bodyLarge,
                      );
                    }
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Create reminder buttons
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.mic,
                    title: 'Voice',
                    subtitle: 'Create by voice',
                    color: Colors.deepPurple,
                    onTap: () => Get.to(() => const VoiceCreatePage()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.edit,
                    title: 'Manual',
                    subtitle: 'Create manually',
                    color: Colors.teal,
                    onTap: () => Get.to(() => const ManualCreatePage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // My reminders and geofence status
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.list,
                    title: 'Reminders',
                    subtitle: 'View all',
                    color: Colors.blue,
                    onTap: () => Get.to(() => const ReminderListPage()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.location_searching,
                    title: 'Geofence',
                    subtitle: 'Status',
                    color: Colors.orange,
                    onTap: () => Get.to(() => const GeofenceStatusPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
