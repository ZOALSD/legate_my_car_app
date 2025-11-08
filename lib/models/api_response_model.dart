import 'car_model.dart';

class ApiResponseModel<T> {
  final bool success;
  final T data;
  final String? message;
  final Map<String, dynamic>? errors;

  ApiResponseModel({
    required this.success,
    required this.data,
    this.message,
    this.errors,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      data: fromJsonT(json['data'] ?? {}),
      message: json['message'],
      errors: json['errors'] != null
          ? Map<String, dynamic>.from(json['errors'])
          : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      'data': toJsonT(data),
      'message': message,
      'errors': errors,
    };
  }
}

class SimplePagination {
  final int currentPage;
  final int total;
  final int lastPage;
  final bool hasMorePages;

  SimplePagination({
    required this.currentPage,
    required this.total,
    required this.lastPage,
    required this.hasMorePages,
  });

  factory SimplePagination.fromJson(Map<String, dynamic> json) {
    return SimplePagination(
      currentPage: json['current_page'] ?? 1,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      hasMorePages: json['has_more_pages'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total': total,
      'last_page': lastPage,
      'has_more_pages': hasMorePages,
    };
  }
}

class CarsApiResponse {
  final List<CarModel> cars;
  final SimplePagination pagination;

  CarsApiResponse({required this.cars, required this.pagination});

  factory CarsApiResponse.fromJson(Map<String, dynamic> json) {
    return CarsApiResponse(
      cars:
          (json['data'] as List<dynamic>?)
              ?.map((carJson) => CarModel.fromJson(carJson))
              .toList() ??
          [],
      pagination: SimplePagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': true,
      'data': cars.map((car) => car.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class ListResponseModel<T> {
  final bool success;
  final String? apiVersion;
  final List<T>? data;
  final SimplePagination? pagination;

  ListResponseModel({
    required this.success,
    this.apiVersion,
    this.data,
    this.pagination,
  });

  factory ListResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ListResponseModel<T>(
      success: json['success'] ?? false,
      apiVersion: json['api_version'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List<dynamic>?)?.map((e) => fromJsonT(e)).toList()
          : [],
      pagination: SimplePagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      'api_version': apiVersion,
      'data': data?.map((e) => toJsonT(e)).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}
