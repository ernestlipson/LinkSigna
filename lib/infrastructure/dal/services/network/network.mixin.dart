// network_mixin.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' as g;

mixin NetworkMixin {
  Dio get dio => Dio(BaseOptions(
        baseUrl: 'https://your-api-base-url.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));

  // Initialize Dio with interceptors
  void initializeNetwork() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add authorization header if needed
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';
        // options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Handle global errors here
        if (error.response?.statusCode == 401) {
          // Handle unauthorized error
          // Get.offAllNamed('/login');
        }
        return handler.next(error);
      },
    ));

    // Add logging interceptor
    dio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      requestBody: true,
      error: true,
    ));
  }

  Future<Response<T>> getRequest<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
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
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException error) {
    String message = 'Unknown error occurred';
    if (error.response != null) {
      message = error.response?.data?['message'] ??
          'Server error ${error.response?.statusCode}';
    } else {
      message = error.message ?? 'Network error occurred';
    }

    // Use GetX to show error dialog or snackbar
    g.Get.snackbar('Error', message);
  }
}
