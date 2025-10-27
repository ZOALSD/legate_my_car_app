import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add authentication token to all requests
    final token = await AuthService.getToken();

    if (token != null && token.isNotEmpty && token != 'demo_token') {
      options.headers['Authorization'] = 'Bearer $token';
      print('🔐 Added Bearer token to request: ${options.path}');
    }

    // Add common headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    // Log request details
    print('📤 REQUEST: ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      print('📤 Query Parameters: ${options.queryParameters}');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response details
    print('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');

    if (response.data != null) {
      print(
        '📥 Response data: ${response.data.toString().substring(0, response.data.toString().length > 200 ? 200 : response.data.toString().length)}...',
      );
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('❌ ERROR: ${err.type} - ${err.message}');
    print('❌ URL: ${err.requestOptions.uri}');
    print('❌ Status Code: ${err.response?.statusCode}');

    // Handle 401 Unauthorized - try to refresh token
    if (err.response?.statusCode == 401) {
      print('⚠️ Unauthorized (401), attempting to re-login...');

      try {
        final loginSuccess = await AuthService.loginAsGuest();

        if (loginSuccess) {
          print('✅ Re-authenticated successfully, retrying request...');

          // Retry the original request with new token
          final token = await AuthService.getToken();
          if (token != null && token.isNotEmpty) {
            err.requestOptions.headers['Authorization'] = 'Bearer $token';

            try {
              final options = err.requestOptions;
              final dio = Dio();
              final response = await dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              print('❌ Retry failed: $e');
            }
          }
        }
      } catch (e) {
        print('❌ Re-authentication failed: $e');
      }
    }

    super.onError(err, handler);
  }
}
