import 'package:get/get.dart';
import '../../models/auth_token.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';
import '../../services/token_refresh_interceptor.dart';
import '../../services/auth_interceptor.dart';

/// Extended Auth Controller with JWT token management
class AuthController extends GetxController {
  late final ApiService _apiService;
  late final TokenStorage _tokenStorage;

  // Observable states
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isTokenRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _checkAuthStatus();
  }

  void _initializeServices() {
    _tokenStorage = TokenStorage();
    _apiService = ApiService(tokenStorage: _tokenStorage);

    // Add token refresh interceptor
    _apiService.addInterceptor(
      TokenRefreshInterceptor(
        tokenStorage: _tokenStorage,
        dio: _apiService.dio,
        onRefreshFailed: _onTokenRefreshFailed,
      ),
    );

    // Add auth interceptor
    _apiService.addInterceptor(
      AuthInterceptor(
        tokenStorage: _tokenStorage,
        onAuthFailed: _onAuthFailed,
      ),
    );
  }

  /// Check authentication status on startup
  Future<void> _checkAuthStatus() async {
    final hasToken = await _tokenStorage.hasToken();
    isLoggedIn.value = hasToken;
  }

  /// Handle token refresh failure
  Future<void> _onTokenRefreshFailed() async {
    await logout();
    errorMessage.value = 'Session expired. Please login again.';
    // Navigate to login will be handled by UI
  }

  /// Handle authentication failure
  void _onAuthFailed() {
    // Could show dialog or redirect to login
  }

  /// Register a new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // TODO: Call actual API when backend is ready
      // final response = await _apiService.post('/user/register', data: {
      //   'username': username,
      //   'email': email,
      //   'password': password,
      // });

      // Simulate API call for now
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock response
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: email,
        subscriptionLevel: 1,
        createdAt: DateTime.now(),
      );

      final token = AuthToken(
        accessToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      );

      // Save token and user
      await _apiService.setAuthToken(token);
      currentUser.value = user;
      isLoggedIn.value = true;

      return true;
    } catch (e) {
      errorMessage.value = 'Registration failed: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // TODO: Call actual API when backend is ready
      // final response = await _apiService.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });

      // Simulate API call for now
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock response
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: email.split('@').first,
        email: email,
        subscriptionLevel: 1,
        createdAt: DateTime.now(),
      );

      final token = AuthToken(
        accessToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      );

      // Save token and user
      await _apiService.setAuthToken(token);
      currentUser.value = user;
      isLoggedIn.value = true;

      return true;
    } catch (e) {
      errorMessage.value = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout - clears all tokens and user data
  Future<void> logout() async {
    isLoading.value = true;

    try {
      // TODO: Call logout API to invalidate token on server
      // await _apiService.post('/auth/logout');

      // Clear local tokens
      await _apiService.clearAuthToken();

      // Clear user data
      currentUser.value = null;
      isLoggedIn.value = false;

      // Clear any local guest session data
      // This would be handled by GuestSessionManager if needed
    } finally {
      isLoading.value = false;
    }
  }

  /// Manually refresh the current token
  Future<bool> refreshToken() async {
    if (isTokenRefreshing.value) return false;

    isTokenRefreshing.value = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await logout();
        return false;
      }

      // TODO: Call actual refresh API
      // final response = await _apiService.post('/auth/refresh', data: {
      //   'refreshToken': refreshToken,
      // });

      // Mock: Simulate token refresh
      await Future.delayed(const Duration(milliseconds: 300));

      final newToken = AuthToken(
        accessToken: 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: refreshToken,
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      );

      await _apiService.setAuthToken(newToken);
      return true;
    } catch (e) {
      errorMessage.value = 'Token refresh failed';
      return false;
    } finally {
      isTokenRefreshing.value = false;
    }
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }

  /// Check if user is logged in
  Future<bool> checkIsLoggedIn() async {
    return await _tokenStorage.hasToken();
  }

  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validate username
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 32) {
      return 'Username must be less than 32 characters';
    }
    return null;
  }
}
