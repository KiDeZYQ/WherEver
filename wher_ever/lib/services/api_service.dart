import 'package:dio/dio.dart';
import '../models/auth_token.dart';
import 'token_storage.dart';

/// API service for making HTTP requests
class ApiService {
  late final Dio _dio;
  final TokenStorage _tokenStorage;

  // Backend services base URLs - in production, use API Gateway
  static const String userServiceUrl = 'http://10.0.2.2:8081'; // Android emulator localhost
  static const String notificationServiceUrl = 'http://10.0.2.2:8082';

  ApiService({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage() {
    _dio = Dio(
      BaseOptions(
        // Default to user service for auth endpoints
        baseUrl: userServiceUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add default interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Get the Dio instance for adding custom interceptors
  Dio get dio => _dio;

  /// Add an interceptor
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Get base URL for a service
  String getBaseUrlForService(String service) {
    switch (service) {
      case 'user':
        return userServiceUrl;
      case 'notification':
        return notificationServiceUrl;
      default:
        return userServiceUrl;
    }
  }

  /// Set base URL (useful for switching between dev/prod)
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Set auth token
  Future<void> setAuthToken(AuthToken token) async {
    await _tokenStorage.saveToken(token);
  }

  /// Clear auth token
  Future<void> clearAuthToken() async {
    await _tokenStorage.clearToken();
  }
}
