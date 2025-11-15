import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:legate_my_car/views/login_view.dart';
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
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Log response details
    print('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    if (response.statusCode == 401) {
      final requestPath = response.requestOptions.path;
      final isLoginEndpoint = requestPath.contains('/login');

      if (!isLoginEndpoint) {
        await AuthService.logout();
        Get.offAll(() => const LoginView());
      }
    }

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

    if (err.response?.statusCode == 401) {
      final requestPath = err.requestOptions.path;
      final isLoginEndpoint = requestPath.contains('/login');

      if (!isLoginEndpoint) {
        await AuthService.logout();
        Get.offAll(() => const LoginView());
      }
    }

    super.onError(err, handler);
  }
}
