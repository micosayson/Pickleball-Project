import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_exception.dart';

/// Singleton HTTP client for all FastAPI backend calls.
///
/// Usage in a service file:
/// ```dart
/// final response = await ApiClient.instance.get('/events');
/// final response = await ApiClient.instance.post('/events', data: {...});
/// ```
///
/// - Automatically attaches the Supabase JWT to every request.
/// - Throws [ApiException] on HTTP errors instead of raw [DioException].
/// - Base URL is set to the FastAPI backend base URL.
class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  // ── Change this to your production URL when deploying ─────────────────
  static const String _baseUrl = 'http://localhost:8000/api/v1';

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(),
    ]);

  // ── Public HTTP methods ────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
}

// ── Interceptor: attach Supabase JWT ──────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token =
        Supabase.instance.client.auth.currentSession?.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// ── Interceptor: convert DioException → ApiException ─────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final serverMessage = err.response?.data is Map
        ? (err.response!.data as Map)['detail']?.toString() ?? ''
        : '';

    throw ApiException(
      statusCode: statusCode,
      message: serverMessage.isNotEmpty ? serverMessage : err.message ?? '',
    );
  }
}
