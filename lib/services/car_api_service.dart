import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';
import '../models/api_response_model.dart';
import '../config/env_config.dart';

class CarApiService {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // Get all cars with pagination
  static Future<CarsApiResponse> getAllCars({
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

      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '$baseUrl/api/v1/cars',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CarsApiResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cars: $e');
    }
  }

  // Get cars by status with pagination
  static Future<CarsApiResponse> getCarsByStatus(
    String status, {
    int page = 1,
    int perPage = 10,
  }) async {
    return getAllCars(page: page, perPage: perPage, status: status);
  }

  // Search cars with pagination
  static Future<CarsApiResponse> searchCars(
    String query, {
    int page = 1,
    int perPage = 10,
    String? status,
  }) async {
    return getAllCars(
      page: page,
      perPage: perPage,
      status: status,
      search: query,
    );
  }

  // Get car by ID
  static Future<CarModel> getCarById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/cars/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/cars'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(car.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
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
      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/cars/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(car.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
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
      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/cars/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting car: $e');
    }
  }

  // Get statistics
  static Future<Map<String, int>> getCarStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/cars/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Map<String, int>.from(jsonData['data'] ?? {});
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching statistics: $e');
    }
  }
}
