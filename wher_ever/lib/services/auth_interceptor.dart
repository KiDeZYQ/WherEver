import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Authentication interceptor for Dio
/// Handles token injection and refresh on 401
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final void Function()? onAuthFailed;

  AuthInterceptor({
    required TokenStorage tokenStorage,
    void Function()? onAuthFailed,
  })  : _tokenStorage = tokenStorage,
        onAuthFailed = onAuthFailed;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Get current token
    final token = await _tokenStorage.loadToken();

    if (token != null && token.isValid) {
      // Add authorization header
      options.headers['Authorization'] = token.authorizationHeader;
      handler.next(options);
    } else if (token != null && token.isExpired) {
      // Token expired, will trigger refresh in error interceptor
      options.headers['Authorization'] = token.authorizationHeader;
      handler.next(options);
    } else {
      // No token
      handler.next(options);
    }
  }

  /// Check if endpoint is public (no auth required)
  bool _isPublicEndpoint(String path) {
    const publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/user/register',
      '/health',
    ];

    for (final endpoint in publicEndpoints) {
      if (path.contains(endpoint)) {
        return true;
      }
    }
    return false;
  }
}
