import 'package:legate_my_car/models/enums/user_status.dart';

class LoginResponse {
  final bool success;
  final String? message;
  final UserStatus? inactiveStatus;

  const LoginResponse({
    required this.success,
    this.message,
    this.inactiveStatus,
  });

  bool get isInactive => inactiveStatus != null;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
