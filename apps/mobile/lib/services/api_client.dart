import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// HTTP client for calling Cloud Functions API.
///
/// In development with emulators, set [baseUrl] to the emulator URL
/// (typically http://127.0.0.1:5001/scab-purdue/us-central1/api).
///
/// In production, this points to the deployed Cloud Functions URL.
class ApiClient {
  ApiClient({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            // Default to emulator URL; overridden in production.
            baseUrl: baseUrl ??
                const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue:
                      'http://10.0.2.2:5001/scab-purdue/us-central1/api',
                ),
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(_AuthInterceptor());
  }

  final Dio _dio;

  /// GET request with automatic auth header.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  /// POST request with automatic auth header.
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
  }) {
    return _dio.post<T>(path, data: data);
  }
}

/// Interceptor that attaches the Firebase ID token to every request.
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log for debugging; in production, add Crashlytics reporting.
    // ignore: avoid_print
    print('[API Error] ${err.requestOptions.path}: ${err.message}');
    handler.next(err);
  }
}
