import 'package:get/get_utils/get_utils.dart';

import '../models/car_model.dart';
import '../models/api_response_model.dart';
import '../config/env_config.dart';
import '../utils/connection_helper.dart';
import 'dio_service.dart';

class ApiService {
  // Get all cars with pagination
  static Future<CarsApiResponse> getAllCars({
    int page = 1,
    int perPage = 10,
    String? chassisNumber,
  }) async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        throw Exception("NO_INTERNET_CONNECTION".tr);
      }

      // Fetch from real API
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (chassisNumber != null && chassisNumber.isNotEmpty) {
        queryParams['chassis_number'] = chassisNumber;
      }

      final endpoint = '${EnvConfig.apiBaseUrl}/cars';

      // Use DioService which has interceptor configured
      final dio = DioService.instance;
      final response = await dio.get(endpoint, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        return CarsApiResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get car by ID
  static Future<CarModel> getCarById(int id) async {
    try {
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        throw Exception('No internet connection');
      }

      final endpoint = '${EnvConfig.apiBaseUrl}/cars/$id';
      final dio = DioService.instance;
      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;

        // Handle API response format: { success: true, data: { ... } }
        if (jsonData['data'] != null &&
            jsonData['data'] is Map<String, dynamic>) {
          return CarModel.fromJson(jsonData['data']);
        }

        // If data is the car object directly
        return CarModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load car: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching car: $e');
    }
  }
}
