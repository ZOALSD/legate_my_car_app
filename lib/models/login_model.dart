import 'dart:convert';

class LoginModel {
  final UserModel user;
  final String token;

  LoginModel({required this.user, required this.token});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token};
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final bool isGuest;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isGuest,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isGuest: json['is_guest'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'is_guest': isGuest};
  }

  String toJsonString() {
    return jsonEncode({
      'id': id,
      'name': name,
      'email': email,
      'is_guest': isGuest,
    });
  }
}

class LoginResponseModel {
  final bool success;
  final String? message;
  final LoginModel data;

  LoginResponseModel({required this.success, this.message, required this.data});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: LoginModel.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class UserInfoResponseModel {
  final bool success;
  final UserModel user;

  UserInfoResponseModel({required this.success, required this.user});

  factory UserInfoResponseModel.fromJson(Map<String, dynamic> json) {
    return UserInfoResponseModel(
      success: json['success'] ?? false,
      user: UserModel.fromJson(json['data']?['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {'user': user.toJson()},
    };
  }
}
