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
    String? status,
    String? search,
  }) async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        print('⚠️ No internet connection, using demo data');
        throw Exception('No internet connection');
      }

      // Fetch from real API
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final endpoint = '${EnvConfig.apiBaseUrl}/cars';

      // Use DioService which has interceptor configured
      final dio = DioService.instance;
      final response = await dio.get(endpoint, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;

        // Debug: print response structure
        print('📦 API Response received');
        print('📦 Has data array: ${jsonData['data'] != null}');
        print('📦 Has pagination: ${jsonData['pagination'] != null}');
        if (jsonData['data'] != null && jsonData['data'] is List) {
          print('📦 Data array length: ${(jsonData['data'] as List).length}');
        }

        final carsResponse = CarsApiResponse.fromJson(jsonData);
        print('✅ Parsed ${carsResponse.cars.length} cars');

        return carsResponse;
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ API unavailable, using demo data: $e');
      print('📝 Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Search cars with pagination
  static Future<CarsApiResponse> searchCars(
    String query, {
    int page = 1,
    int perPage = 10,
    String? status,
  }) async {
    try {
      final response = await getAllCars(
        page: page,
        perPage: perPage,
        status: status,
        search: query,
      );
      return response;
    } catch (e) {
      throw Exception('Error searching cars: $e');
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
