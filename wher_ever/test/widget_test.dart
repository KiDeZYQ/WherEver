// Basic Flutter widget test for WherEver app

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wher_ever/services/auth_service.dart';
import 'package:wher_ever/services/guest_session_manager.dart';
import 'package:wher_ever/services/guest_session_storage.dart';
import 'package:wher_ever/main.dart';

void main() {
  testWidgets('WherEver app smoke test', (WidgetTester tester) async {
    // Set up mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Initialize services
    final guestStorage = GuestSessionStorage(prefs);
    final guestManager = GuestSessionManager(guestStorage);
    final authService = AuthService(guestManager);

    // Initialize authentication
    await authService.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(WherEverApp(authService: authService));

    // Verify that the welcome text is displayed
    expect(find.text('Welcome to WherEver'), findsOneWidget);

    // Verify that guest mode text is displayed
    expect(find.textContaining('Guest Mode'), findsOneWidget);
  });
}
