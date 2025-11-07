import 'missing_car_model.dart';

class LostCarRequestModel {
  final String id;
  final int requestNumber;
  final String chassisNumber;
  final String plateNumber;
  final String? carName;
  final String model;
  final String color;
  final String lastKnownLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  LostCarRequestModel({
    required this.id,
    required this.requestNumber,
    required this.chassisNumber,
    required this.plateNumber,
    this.carName,
    required this.model,
    required this.color,
    required this.lastKnownLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LostCarRequestModel.fromJson(Map<String, dynamic> json) {
    return LostCarRequestModel(
      id: json['id']?.toString() ?? '',
      requestNumber: json['request_number'] ?? 0,
      chassisNumber: json['chassis_number'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      carName: json['car_name'],
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      lastKnownLocation: json['last_known_location'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chassis_number': chassisNumber,
      'plate_number': plateNumber,
      if (carName != null) 'car_name': carName,
      'model': model,
      'color': color,
      'last_known_location': lastKnownLocation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullCarName => model;

  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Convert to MissingCarModel for compatibility with existing views
  MissingCarModel toMissingCarModel() {
    return MissingCarModel(
      id: int.tryParse(id) ?? 0,
      originalRequestId: id, // Store original UUID string
      plateNumber: plateNumber,
      chassisNumber: chassisNumber,
      brand: carName ?? '', // Use car_name if available
      model: model,
      color: color,
      description: '', // Not available in API
      imagePath: null,
      userId: 0, // Not available in API
      status: 'missing',
      missingDate: createdAt,
      lastKnownLocation: lastKnownLocation,
      contactInfo: '',
      rewardAmount: null,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
