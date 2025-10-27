import 'package:dio/dio.dart';
import '../models/car_model.dart';
import '../models/api_response_model.dart';
import '../config/env_config.dart';

class CarApiService {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // Get all cars with pagination
  static Future<CarsApiResponse> getCars({
    int page = 1,
    int perPage = 10,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final dio = Dio(
        BaseOptions(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await dio.get(
        '$baseUrl/api/v1/cars',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        return CarsApiResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cars: $e');
    }
  }

  // Get car by ID
  static Future<CarModel> getCarById(int id) async {
    try {
      final dio = Dio(
        BaseOptions(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await dio.get('$baseUrl/api/v1/cars/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final apiResponse = ApiResponseModel.fromJson(
          jsonData,
          (data) => CarModel.fromJson(data),
        );
        return apiResponse.data;
      } else {
        throw Exception('Failed to load car: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching car: $e');
    }
  }

  // Create new car report
  static Future<CarModel> createCar(CarModel car) async {
    try {
      final dio = Dio(
        BaseOptions(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await dio.post(
        '$baseUrl/api/v1/cars',
        data: car.toJson(),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = response.data;
        final apiResponse = ApiResponseModel.fromJson(
          jsonData,
          (data) => CarModel.fromJson(data),
        );
        return apiResponse.data;
      } else {
        throw Exception('Failed to create car: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating car: $e');
    }
  }

  // Update car report
  static Future<CarModel> updateCar(int id, CarModel car) async {
    try {
      final dio = Dio(
        BaseOptions(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await dio.put(
        '$baseUrl/api/v1/cars/$id',
        data: car.toJson(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final apiResponse = ApiResponseModel.fromJson(
          jsonData,
          (data) => CarModel.fromJson(data),
        );
        return apiResponse.data;
      } else {
        throw Exception('Failed to update car: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating car: $e');
    }
  }

  // Delete car report
  static Future<bool> deleteCar(int id) async {
    try {
      final dio = Dio(
        BaseOptions(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await dio.delete('$baseUrl/api/v1/cars/$id');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting car: $e');
    }
  }
}
