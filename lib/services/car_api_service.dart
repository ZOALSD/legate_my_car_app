import 'dart:io';
import 'package:dio/dio.dart';
import '../models/car_model.dart';
import '../models/api_response_model.dart';
import '../config/env_config.dart';
import 'auth_service.dart';

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

  // Create new car report with multipart form data
  static Future<CarModel> createCar({
    required String? plateNumber,
    required String? chassisNumber,
    required String? brand,
    required String? model,
    required String? description,
    required String? location,
    required String? latitude,
    required String? longitude,
    File? imageFile,
  }) async {
    try {
      final authHeaders = await AuthService.getAuthHeaders();

      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://${EnvConfig.defaultApiUrl}',
          headers: {
            'Accept': 'application/json',
            'Authorization': authHeaders['Authorization'],
          },
        ),
      );

      // Create FormData for multipart request
      final formData = FormData.fromMap({
        'plate_number': plateNumber,
        'chassis_number': chassisNumber,
        'brand': brand,
        'model': model,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'lost', // Default status
        if (imageFile != null)
          'image_path': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await dio.post('$baseUrl/cars', data: formData);

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
