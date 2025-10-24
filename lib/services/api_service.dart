// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../models/car_model.dart';
import '../models/api_response_model.dart';
import '../config/env_config.dart';
import 'demo_data_service.dart';

class ApiService {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // Get all cars with pagination
  static Future<CarsApiResponse> getAllCars({
    int page = 1,
    int perPage = 10,
    String? status,
    String? search,
  }) async {
    try {
      // For demo purposes, return real data with pagination
      // In production, uncomment the HTTP call below
      await Future.delayed(
        const Duration(seconds: 5),
      ); // Simulate network delay

      final demoService = DemoDataService();
      final response = demoService.getDemoCars(currentPage: page);
      return CarsApiResponse.fromJson(response);

      /* Uncomment for real API integration
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

      final uri = Uri.parse('$baseUrl/api/v1/cars').replace(
        queryParameters: queryParams,
      );

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
      */
    } catch (e) {
      throw Exception('Error fetching cars: $e');
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
      // For demo purposes, use demo data service
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate network delay

      final demoService = DemoDataService();
      final response = demoService.getDemoCars(currentPage: page);
      final carsApiResponse = CarsApiResponse.fromJson(response);

      // Filter cars by search query
      if (query.isNotEmpty) {
        final filteredCars = carsApiResponse.cars.where((car) {
          return car.plateNumber.toLowerCase().contains(query.toLowerCase()) ||
              car.brand.toLowerCase().contains(query.toLowerCase()) ||
              car.model.toLowerCase().contains(query.toLowerCase()) ||
              car.color.toLowerCase().contains(query.toLowerCase()) ||
              car.location.toLowerCase().contains(query.toLowerCase()) ||
              car.description.toLowerCase().contains(query.toLowerCase());
        }).toList();

        return CarsApiResponse(
          cars: filteredCars,
          pagination: carsApiResponse.pagination,
        );
      }

      return carsApiResponse;

      /* Uncomment for real API integration
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        'search': query,
      };

      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/api/v1/cars').replace(
        queryParameters: queryParams,
      );

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
        throw Exception('Failed to search cars: ${response.statusCode}');
      }
      */
    } catch (e) {
      throw Exception('Error searching cars: $e');
    }
  }

  // Get car by ID
  static Future<CarModel> getCarById(int id) async {
    try {
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // Simulate network delay

      // Search through all pages to find the car
      final demoService = DemoDataService();
      for (int page = 1; page <= 5; page++) {
        final response = demoService.getDemoCars(currentPage: page);
        final carsApiResponse = CarsApiResponse.fromJson(response);

        try {
          return carsApiResponse.cars.firstWhere((car) => car.id == id);
        } catch (e) {
          // Continue to next page
        }
      }

      throw Exception('Car with id $id not found');

      /* Uncomment for real API integration
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
      */
    } catch (e) {
      throw Exception('Error fetching car: $e');
    }
  }

  // Filter cars by status with pagination
  static Future<CarsApiResponse> getCarsByStatus(
    String status, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate network delay

      final demoService = DemoDataService();
      final response = demoService.getDemoCars(currentPage: page);
      final carsApiResponse = CarsApiResponse.fromJson(response);

      // Filter cars by status
      if (status != 'all') {
        final filteredCars = carsApiResponse.cars
            .where((car) => car.status == status)
            .toList();
        return CarsApiResponse(
          cars: filteredCars,
          pagination: carsApiResponse.pagination,
        );
      }

      return carsApiResponse;

      /* Uncomment for real API integration
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (status != 'all') {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/api/v1/cars').replace(
        queryParameters: queryParams,
      );

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
        throw Exception('Failed to load cars by status: ${response.statusCode}');
      }
      */
    } catch (e) {
      throw Exception('Error fetching cars by status: $e');
    }
  }

  // Get car statistics
  static Future<Map<String, int>> getCarStatistics() async {
    try {
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // Simulate network delay

      final stats = <String, int>{};
      final demoService = DemoDataService();

      // Get statistics from all pages
      for (int page = 1; page <= 5; page++) {
        final response = demoService.getDemoCars(currentPage: page);
        final carsApiResponse = CarsApiResponse.fromJson(response);

        for (final car in carsApiResponse.cars) {
          stats[car.status] = (stats[car.status] ?? 0) + 1;
        }
      }

      return stats;

      /* Uncomment for real API integration
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
      */
    } catch (e) {
      throw Exception('Error fetching statistics: $e');
    }
  }
}
