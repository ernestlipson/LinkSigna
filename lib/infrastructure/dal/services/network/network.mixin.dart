// network_mixin.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' as g;

mixin NetworkMixin {
  final Dio _dio = Dio();

  // Base URL should be configurable
  String get baseUrl => 'https://restcountries.com/v3.1';

  // Timeouts should be configurable
  Duration get connectTimeout => const Duration(seconds: 30);
  Duration get receiveTimeout => const Duration(seconds: 30);

  Dio get dio => _dio;

  // Initialize Dio with interceptors
  void initializeNetwork() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      contentType: 'application/json',
      responseType: ResponseType.json,
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add authorization header if needed
        options.headers['Accept'] = 'application/json';

        // Uncomment when authentication is implemented
        // final token = Get.find<AuthService>().token;
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Process successful responses
        return handler.next(response);
      },
      onError: (DioException error, handler) async {
        // Handle global errors here
        if (error.response?.statusCode == 401) {
          // Handle unauthorized error
          // g.Get.offAllNamed('/login');
        }
        return handler.next(error);
      },
    ));

    // Add logging interceptor in debug mode
    assert(() {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
      return true;
    }());
  }

  Future<Response<T>> getRequest<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response<T>> postRequest<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response<T>> putRequest<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response<T>> deleteRequest<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response<T>> patchRequest<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  CancelToken createCancelToken() {
    return CancelToken();
  }

  void _handleError(DioException error) {
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad server certificate.';
        break;
      case DioExceptionType.badResponse:
        message = _parseErrorResponse(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.unknown:
      default:
        message = error.message ?? 'An unknown error occurred';
        break;
    }

    // Use GetX to show error dialog or snackbar
    g.Get.snackbar(
      'Error',
      message,
      snackPosition: g.SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  String _parseErrorResponse(Response? response) {
    if (response == null) return 'Server error occurred';

    try {
      // Try to extract error message from response data
      if (response.data is Map) {
        final data = response.data as Map;
        if (data.containsKey('message')) {
          return data['message'].toString();
        } else if (data.containsKey('error')) {
          return data['error'].toString();
        }
      }

      // Default message based on status code
      switch (response.statusCode) {
        case 400:
          return 'Bad request';
        case 401:
          return 'Unauthorized';
        case 403:
          return 'Forbidden';
        case 404:
          return 'Not found';
        case 500:
          return 'Internal server error';
        default:
          return 'Server error ${response.statusCode}';
      }
    } catch (e) {
      return 'Error processing server response';
    }
  }
}
