import 'package:dio/dio.dart';
import 'dio_interceptor.dart';
import '../config/env_config.dart';

class DioService {
  static Dio? _dio;

  /// Get singleton Dio instance with interceptors
  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: EnvConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add interceptor
      _dio!.interceptors.add(DioInterceptor());

      print('✅ Dio instance created with interceptor');
    }

    return _dio!;
  }

  /// Reset Dio instance (useful for testing)
  static void reset() {
    _dio = null;
  }
}

// 125
//
