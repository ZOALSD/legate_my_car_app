import 'package:dio/dio.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:legate_my_car/models/api_response_model.dart';
import 'package:legate_my_car/services/dio_service.dart';
import 'package:legate_my_car/utils/connection_helper.dart';
import '../models/lost_car_model.dart';

class LostCarRequestService {
  static final dio = DioService.instance;

  static Future<ListResponseModel<LostCarModel>> getLostCarRequests({
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

      final listResponse = ListResponseModel.fromJson(
        response.data as Map<String, dynamic>,
        (data) => LostCarModel.fromJson(data),
      );

      return listResponse;
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
  static Future<LostCarModel> updateLostCarRequest({
    required LostCarModel lostCar,
  }) async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        throw Exception("NO_INTERNET_CONNECTION".tr);
      }

      final endpoint = '/lost-car-requests/${lostCar.id}';

      // Use DioService which has interceptor configured
      final response = await dio.put(endpoint, data: lostCar.toJson());

      final dynamic body = response.data;
      return LostCarModel.fromJson(body);
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
  static Future<LostCarModel> createLostCarRequest({
    required LostCarModel lostCar,
  }) async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        throw Exception("NO_INTERNET_CONNECTION".tr);
      }

      final endpoint = '/lost-car-requests';

      // Use DioService which has interceptor configured
      final response = await dio.post(endpoint, data: lostCar.toJson());

      final dynamic body = response.data;
      if (body['success']) {
        return LostCarModel.fromJson(body['data']);
      } else {
        throw Exception(body['message']);
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
