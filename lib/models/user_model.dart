import 'package:legate_my_car/models/enums/account_type.dart';
import 'package:legate_my_car/models/enums/user_status.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final UserStatus status;
  final AccountType accountType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isGuest;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.accountType,
    required this.createdAt,
    required this.updatedAt,
    required this.isGuest,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      status: json.containsKey('status')
          ? UserStatus.values.byName(json['status'])
          : UserStatus.active,
      accountType: json.containsKey('accountType')
          ? AccountType.values.byName(json['accountType'])
          : AccountType.client,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isGuest: json.containsKey('isGuest') ? json['isGuest'] : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status,
      'accountType': accountType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isGuest': isGuest,
    };
  }
}
