import 'package:dio/dio.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:legate_my_car/models/api_response_model.dart';
import 'package:legate_my_car/models/user_model.dart';
import 'package:legate_my_car/services/dio_service.dart';
import 'package:legate_my_car/utils/connection_helper.dart';

class UserApiService {
  static final dio = DioService.instance;

  static Future<ListResponseModel<UserModel>> getUsers({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        throw Exception("NO_INTERNET_CONNECTION".tr);
      }

      final response = await dio.get(
        '/auth/users',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      if (response.statusCode == 200) {
        return ListResponseModel.fromJson(
          response.data,
          (data) => UserModel.fromJson(data),
        );
      } else {
        return ListResponseModel(success: false, data: [], pagination: null);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("CONNECTION_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("RECEIVE_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("CONNECTION_ERROR".tr);
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception(
          'Failed to load users: ${e.response?.statusCode ?? "Unknown error"}',
        );
      } else {
        throw Exception('Network error: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserModel> updateUser({
    required int id,
    required String name,
    required String email,
    required String status,
    required String accountType,
  }) async {
    try {
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        throw Exception("NO_INTERNET_CONNECTION".tr);
      }

      final response = await dio.put(
        '/auth/users/$id',
        data: {
          'name': name,
          'email': email,
          'status': status,
          'account_type': accountType,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw Exception('USER_UPDATE_ERROR'.tr);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("CONNECTION_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("RECEIVE_TIMEOUT".tr);
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception("CONNECTION_ERROR".tr);
      } else if (e.type == DioExceptionType.badResponse) {
        final message =
            e.response?.data?['message'] ??
            'Failed to update user: ${e.response?.statusCode ?? "Unknown error"}';
        throw Exception(message);
      } else {
        throw Exception('Network error: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
