import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/guest_session_manager.dart';
import 'services/guest_session_storage.dart';
import 'services/reminder_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/geofence_service.dart';
import 'pages/auth/auth_controller.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'home_page.dart';
import 'pages/home/voice_create_page.dart';
import 'pages/home/manual_create_page.dart';
import 'pages/home/reminder_list_page.dart';
import 'pages/home/reminder_detail_page.dart';
import 'pages/home/edit_reminder_page.dart';
import 'pages/home/location_search_page.dart';
import 'pages/home/map_select_page.dart';
import 'pages/home/geofence_status_page.dart';
import 'pages/home/settings_page.dart';
import 'pages/home/data_export_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize services
  final guestStorage = GuestSessionStorage(prefs);
  final guestManager = GuestSessionManager(guestStorage);
  final authService = AuthService(guestManager);

  // Initialize authentication
  await authService.initialize();

  // Register AuthController with GetX
  Get.put(AuthController());

  // Register services
  Get.put(ReminderService());
  Get.put(LocationService());
  Get.put(NotificationService());
  Get.put(GeofenceService());

  runApp(WherEverApp(authService: authService));
}

class WherEverApp extends StatelessWidget {
  final AuthService authService;

  const WherEverApp({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WherEver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),
        GetPage(name: '/reminder/create/voice', page: () => const VoiceCreatePage()),
        GetPage(name: '/reminder/create/manual', page: () => const ManualCreatePage()),
        GetPage(name: '/reminders', page: () => const ReminderListPage()),
        GetPage(name: '/reminder/:id', page: () => const ReminderDetailPage()),
        GetPage(name: '/reminder/edit/:id', page: () => const EditReminderPage()),
        GetPage(name: '/location/search', page: () => const LocationSearchPage()),
        GetPage(name: '/location/map', page: () => const MapSelectPage()),
        GetPage(name: '/geofence/status', page: () => const GeofenceStatusPage()),
        GetPage(name: '/settings', page: () => const SettingsPage()),
        GetPage(name: '/data/export', page: () => const DataExportPage()),
      ],
    );
  }
}
