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
    try {
      return ListResponseModel<T>(
        success: json['success'] ?? false,
        apiVersion: json['api_version'] ?? '',
        data: json['data'] != null
            ? (json['data'] as List<dynamic>?)
                  ?.map((e) => fromJsonT(e))
                  .toList()
            : [],
        pagination: SimplePagination.fromJson(json['pagination'] ?? {}),
      );
    } catch (e) {
      print('❌ Error parsing ListResponseModel: $e');
      return ListResponseModel(success: false, data: [], pagination: null);
    }
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
