import 'package:dio/dio.dart';
import 'api_config.dart';
import 'api_response.dart';
import '../storage/auth_storage.dart';

/// Core API Service using Dio
/// Handles all HTTP requests with proper error handling and token management
class ApiService {
  late final Dio _dio;
  final AuthStorage _authStorage;

  ApiService({AuthStorage? authStorage})
      : _authStorage = authStorage ?? AuthStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Log request for debugging
          print(
              '🌐 API Request: ${options.method} ${options.baseUrl}${options.path}');

          // Attach auth token if available
          final token = await _authStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔑 Token attached: ${token.substring(0, 20)}...');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              '✅ API Response: ${response.statusCode} - ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('❌ API Error: ${error.type} - ${error.message}');
          print('   Endpoint: ${error.requestOptions.path}');

          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            await _authStorage.clearAuth();
            // Let the app handle navigation to welcome page
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      return _handleResponse(response, parser);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      return _handleResponse(response, parser);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _handleResponse(response, parser);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.delete(endpoint);
      return _handleResponse(response, parser);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Handle successful response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? parser,
  ) {
    final data = response.data;

    // Check if response has success flag
    if (data is Map<String, dynamic>) {
      final success = data['success'] ?? true;
      final message = data['message'] as String?;

      if (!success) {
        return ApiResponse.error(
          message ?? 'Request failed',
          statusCode: response.statusCode,
          errors: data['errors'] as Map<String, dynamic>?,
        );
      }

      // Parse data if parser provided
      final parsedData =
          parser != null ? parser(data['data']) : data['data'] as T?;

      return ApiResponse.success(
        parsedData as T,
        message: message,
        statusCode: response.statusCode,
      );
    }

    // Fallback for non-standard responses
    final parsedData = parser != null ? parser(data) : data as T?;
    return ApiResponse.success(
      parsedData as T,
      statusCode: response.statusCode,
    );
  }

  /// Handle DioException errors
  ApiResponse<T> _handleError<T>(DioException error) {
    String message;
    Map<String, dynamic>? errors;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;

      case DioExceptionType.badResponse:
        final response = error.response;
        final data = response?.data;

        if (data is Map<String, dynamic>) {
          message = data['message'] ?? 'Request failed';
          errors = data['errors'] as Map<String, dynamic>?;
        } else {
          message = 'Server error: ${response?.statusCode}';
        }
        break;

      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;

      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;

      default:
        message = 'An unexpected error occurred';
    }

    return ApiResponse.error(
      message,
      statusCode: error.response?.statusCode,
      errors: errors,
    );
  }
}
