import 'package:dio/dio.dart';
import 'package:get/get.dart' as g;

mixin NetworkMixin {
  final Dio _dio = Dio();
  String _baseUrl = 'https://restcountries.com/v3.1';

  String get baseUrl => _baseUrl;
  set baseUrl(String value) {
    _baseUrl = value;
    if (_dio.options.baseUrl != value) _dio.options.baseUrl = value;
  }

  Dio get dio => _dio;

  void initializeNetwork() {
    _setupDioOptions();
    _addInterceptors();
    _addLoggingInDebugMode();
  }

  Future<Response<T>> getRequest<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _executeRequest(() => _dio.get<T>(
            path,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          ));

  Future<Response<T>> postRequest<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _executeRequest(() => _dio.post<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          ));

  Future<Response<T>> putRequest<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _executeRequest(() => _dio.put<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          ));

  Future<Response<T>> deleteRequest<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _executeRequest(() => _dio.delete<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          ));

  Future<Response<T>> patchRequest<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _executeRequest(() => _dio.patch<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          ));

  CancelToken createCancelToken() => CancelToken();

  Future<Response<T>> _executeRequest<T>(
      Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _setupDioOptions() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
    );
  }

  void _addInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized error
        }
        return handler.next(error);
      },
    ));
  }

  void _addLoggingInDebugMode() {
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

  void _handleError(DioException error) {
    final message = _getErrorMessage(error);
    g.Get.snackbar(
      'Error',
      message,
      snackPosition: g.SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badCertificate:
        return 'Bad server certificate.';
      case DioExceptionType.badResponse:
        return _parseErrorResponse(error.response);
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.unknown:
        return error.message ?? 'An unknown error occurred';
    }
  }

  String _parseErrorResponse(Response? response) {
    if (response == null) return 'Server error occurred';

    if (response.data is Map) {
      final data = response.data as Map;
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) return data['error'].toString();
    }

    return switch (response.statusCode) {
      400 => 'Bad request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not found',
      500 => 'Internal server error',
      _ => 'Server error ${response.statusCode}'
    };
  }
}
