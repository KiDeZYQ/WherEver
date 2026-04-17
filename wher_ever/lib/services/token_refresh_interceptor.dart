import 'package:dio/dio.dart';
import '../models/auth_token.dart';
import 'token_storage.dart';

/// Interceptor that handles JWT token refresh on 401 responses
class TokenRefreshInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;
  final Future<void> Function() onRefreshFailed;

  bool _isRefreshing = false;
  final List<_RequestRetryInfo> _pendingRequests = [];

  TokenRefreshInterceptor({
    required TokenStorage tokenStorage,
    required Dio dio,
    required this.onRefreshFailed,
  })  : _tokenStorage = tokenStorage,
        _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshed = await _refreshToken();
          _isRefreshing = false;

          if (refreshed) {
            // Retry all pending requests
            for (final request in _pendingRequests) {
              await _retryRequest(request);
            }
            _pendingRequests.clear();

            // Don't call handler.next - requests were retried
            return;
          }
        } catch (e) {
          _isRefreshing = false;
          _pendingRequests.clear();
        }

        // Refresh failed
        await onRefreshFailed();
      } else {
        // Already refreshing, add to queue
        _pendingRequests.add(_RequestRetryInfo(
          requestOptions: err.requestOptions,
          complete: false,
        ));
        return;
      }
    }

    handler.next(err);
  }

  /// Refresh the access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      // TODO: Call actual refresh API when backend is ready
      // final response = await _dio.post('/auth/refresh', data: {
      //   'refreshToken': refreshToken,
      // });

      // Mock: Simulate token refresh
      await Future.delayed(const Duration(milliseconds: 300));

      final newToken = AuthToken(
        accessToken: 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: refreshToken,
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      );

      await _tokenStorage.saveToken(newToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Retry a failed request with new token
  Future<void> _retryRequest(_RequestRetryInfo requestInfo) async {
    try {
      // Get new token
      final token = await _tokenStorage.loadToken();
      if (token == null) return;

      // Update request headers
      final options = Options(
        method: requestInfo.requestOptions.method,
        headers: {
          ...requestInfo.requestOptions.headers,
          'Authorization': token.authorizationHeader,
        },
      );

      // Retry request
      await _dio.request(
        requestInfo.requestOptions.path,
        data: requestInfo.requestOptions.data,
        queryParameters: requestInfo.requestOptions.queryParameters,
        options: options,
      );
    } catch (e) {
      // Retry failed
    }
  }
}

/// Internal class to track pending requests during token refresh
class _RequestRetryInfo {
  final RequestOptions requestOptions;
  final bool complete;

  _RequestRetryInfo({
    required this.requestOptions,
    required this.complete,
  });
}
