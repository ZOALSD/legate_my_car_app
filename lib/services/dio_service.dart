import 'package:dio/dio.dart';
import 'package:legate_my_car/config/app_flavor.dart';
import 'dio_interceptor.dart';
import '../config/env_config.dart';

class DioService {
  static Dio? _dio;
  static final String nameSpace = AppFlavorConfig.isManagers
      ? 'managers'
      : 'clients';

  /// Get singleton Dio instance with interceptors
  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: "${EnvConfig.apiBaseUrl}/$nameSpace",
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          // Don't throw exceptions for 4xx status codes (400-499)
          // They will be returned as valid responses that can be handled manually
          validateStatus: (status) {
            return status != null && status < 500;
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
