import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:legate_my_car/services/dio_service.dart';
import 'package:legate_my_car/utils/connection_helper.dart';
import '../models/car_model.dart';
import '../models/api_response_model.dart';

class CarApiService {
  // Get all cars with pagination
  static final dio = DioService.instance;

  static Future<ListResponseModel<CarModel>> getAllCars({
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
        queryParams['query'] = chassisNumber;
      }

      final endpoint = '/cars';

      // Use DioService which has interceptor configured
      final response = await dio.get(endpoint, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final listResponseModel = ListResponseModel.fromJson(
          jsonData,
          (data) => CarModel.fromJson(data),
        );

        return listResponseModel;
      } else {
        return ListResponseModel(success: false, data: [], pagination: null);
      }
    } on DioException catch (e) {
      // Handle specific DioException types
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("CONNECTION_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("RECEIVE_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("CONNECTION_ERROR".tr);
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception(
          'Failed to load cars: ${e.response?.statusCode ?? "Unknown error"}',
        );
      } else {
        throw Exception('Network error: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get car by ID
  static Future<CarModel> getCarById(int id) async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        throw Exception("NO_INTERNET_CONNECTION".tr);
      }

      final response = await dio.get('/cars/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        return CarModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to load car: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle specific DioException types
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("CONNECTION_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("RECEIVE_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("CONNECTION_ERROR".tr);
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception(
          'Failed to load car: ${e.response?.statusCode ?? "Unknown error"}',
        );
      } else {
        throw Exception('Network error: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error fetching car: $e');
    }
  }

  // Create new car report with multipart form data
  static Future<CarModel> createCar({
    required CarModel car,
    File? imageFile,
  }) async {
    try {
      final carJson = car.toJson();
      final formData = FormData.fromMap({...carJson});

      if (imageFile != null) {
        formData.files.add(
          MapEntry('image_path', await MultipartFile.fromFile(imageFile.path)),
        );
      }

      final response = await dio.post('/cars', data: formData);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.data);
        return CarModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to create car: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🚨 Error creating car: ${e.message}');
      // Handle specific DioException types
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("CONNECTION_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("RECEIVE_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("CONNECTION_ERROR".tr);
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception(
          'Failed to create car: ${e.response?.statusCode ?? "Unknown error"}',
        );
      } else {
        throw Exception('Network error: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error creating car: $e');
    }
  }

  // Update car report with multipart form data
  static Future<CarModel> updateCar({
    required CarModel car,
    File? imageFile,
  }) async {
    try {
      final carJson = car.toJson();
      final formData = FormData.fromMap({...carJson});

      if (imageFile != null) {
        formData.files.add(
          MapEntry('image_path', await MultipartFile.fromFile(imageFile.path)),
        );
      }

      final response = await dio.post('/cars/${car.id}/update', data: formData);

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.data);
        return CarModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update car: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle specific DioException types
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("CONNECTION_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("RECEIVE_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("CONNECTION_ERROR".tr);
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception(
          'Failed to update car: ${e.response?.statusCode ?? "Unknown error"}',
        );
      } else {
        throw Exception('Network error: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Error updating car: $e');
    }
  }
}
