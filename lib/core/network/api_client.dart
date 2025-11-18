import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/storage_utils.dart';

/// API client for making HTTP requests
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging (optional)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (log) => print('[API] $log'),
      ),
    );
  }

  /// GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    try {
      final options = Options();
      if (requiresAuth) {
        final token = await StorageUtils.getToken();
        print('[API Client] Requires Auth: $requiresAuth');
        print('[API Client] Token from storage: ${token != null ? "${token.substring(0, 20)}..." : "null"}');
        if (token != null) {
          options.headers = {'Authorization': 'Bearer $token'};
          print('[API Client] Authorization header set');
        } else {
          print('[API Client] WARNING: No token found in storage!');
        }
      }
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors
  String _handleError(DioException error) {
    String errorMessage = 'An unexpected error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please check your internet connection.';
        break;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              errorMessage = 'Bad request. Please check your input.';
              break;
            case 401:
              errorMessage = 'Unauthorized. Invalid credentials.';
              break;
            case 403:
              errorMessage = 'Access forbidden.';
              break;
            case 404:
              errorMessage = 'Resource not found.';
              break;
            case 500:
              errorMessage = 'Internal server error. Please try again later.';
              break;
            default:
              errorMessage = 'Server error: $statusCode';
          }
        }
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled.';
        break;

      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection. Please check your network.';
        break;

      case DioExceptionType.unknown:
        errorMessage = 'Connection failed. Please check your internet connection.';
        break;

      default:
        errorMessage = 'An unexpected error occurred.';
    }

    return errorMessage;
  }
}
