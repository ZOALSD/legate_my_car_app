import 'package:legate_my_car/models/enums/lost_status.dart';

class LostCarModel {
  final String? id;
  final int? requestNumber;
  final String? carName;
  final String? chassisNumber;
  final String? plateNumber;
  final String? model;
  final String? color;
  final String? lastKnownLocation;
  final String? phoneNumber;
  final LostStatus? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LostCarModel({
    this.id,
    this.requestNumber,
    this.carName,
    this.chassisNumber,
    this.plateNumber,
    this.model,
    this.color,
    this.lastKnownLocation,
    this.phoneNumber,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory LostCarModel.fromJson(Map<String, dynamic> json) {
    return LostCarModel(
      id: json['id']?.toString() ?? '',
      requestNumber: json['request_number'] ?? 0,
      carName: json['car_name'],
      chassisNumber: json['chassis_number'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      lastKnownLocation: json['last_known_location'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] != null
          ? LostStatus.values.byName(json['status'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_name': carName,
      'chassis_number': chassisNumber,
      'plate_number': plateNumber,
      'model': model,
      'color': color,
      'last_known_location': lastKnownLocation,
      'phone_number': phoneNumber,
      'status': status?.name,
    };
  }
}
