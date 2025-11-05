import 'package:dio/dio.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:legate_my_car/services/dio_service.dart';
import 'package:legate_my_car/utils/connection_helper.dart';
import '../models/api_response_model.dart';
import '../models/lost_car_request_model.dart';

class LostCarRequestService {
  static final dio = DioService.instance;

  static Future<LostCarRequestsApiResponse> getLostCarRequests({
    int page = 1,
    int perPage = 10,
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

      final endpoint = '/lost-car-requests';

      // Use DioService which has interceptor configured
      final response = await dio.get(endpoint, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        return LostCarRequestsApiResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load lost car requests: ${response.statusCode}',
        );
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
          'Failed to load lost car requests: ${e.response?.statusCode ?? "Unknown error"}',
        );
      } else {
        throw Exception('Network error: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update a lost car request
  static Future<LostCarRequestModel> updateLostCarRequest({
    required String id,
    required String chassisNumber,
    required String plateNumber,
    required String model,
    required String color,
    required String lastKnownLocation,
  }) async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        throw Exception("NO_INTERNET_CONNECTION".tr);
      }

      final endpoint = '/lost-car-requests/$id';

      // Prepare request body
      final requestData = {
        'chassis_number': chassisNumber,
        'plate_number': plateNumber,
        'model': model,
        'color': color,
        'last_known_location': lastKnownLocation,
      };

      // Use DioService which has interceptor configured
      final response = await dio.put(endpoint, data: requestData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        // API might return the updated request in data field or directly
        if (jsonData.containsKey('data')) {
          return LostCarRequestModel.fromJson(
            jsonData['data'] as Map<String, dynamic>,
          );
        } else {
          return LostCarRequestModel.fromJson(jsonData);
        }
      } else {
        throw Exception(
          'Failed to update lost car request: ${response.statusCode}',
        );
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
          'Failed to update lost car request: ${e.response?.statusCode ?? "Unknown error"}',
        );
      } else {
        throw Exception('Network error: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new lost car request
  static Future<LostCarRequestModel> createLostCarRequest({
    required String chassisNumber,
    required String plateNumber,
    required String model,
    required String color,
    required String lastKnownLocation,
  }) async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        throw Exception("NO_INTERNET_CONNECTION".tr);
      }

      final endpoint = '/lost-car-requests';

      // Prepare request body
      final requestData = {
        'chassis_number': chassisNumber,
        'plate_number': plateNumber,
        'model': model,
        'color': color,
        'last_known_location': lastKnownLocation,
      };

      // Use DioService which has interceptor configured
      final response = await dio.post(endpoint, data: requestData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        // API might return the created request in data field or directly
        if (jsonData.containsKey('data')) {
          return LostCarRequestModel.fromJson(
            jsonData['data'] as Map<String, dynamic>,
          );
        } else {
          return LostCarRequestModel.fromJson(jsonData);
        }
      } else {
        throw Exception(
          'Failed to create lost car request: ${response.statusCode}',
        );
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
          'Failed to create lost car request: ${e.response?.statusCode ?? "Unknown error"}',
        );
      } else {
        throw Exception('Network error: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
