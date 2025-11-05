class MissingCarModel {
  final int id;
  final String? originalRequestId; // Store original UUID string from API
  final String plateNumber;
  final String chassisNumber;
  final String brand;
  final String model;
  final String color;
  final String description;
  final String? imagePath;
  final int userId;
  final String status;
  final DateTime missingDate;
  final String lastKnownLocation;
  final String contactInfo;
  final String? rewardAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  MissingCarModel({
    required this.id,
    this.originalRequestId,
    required this.plateNumber,
    required this.chassisNumber,
    required this.brand,
    required this.model,
    required this.color,
    required this.description,
    this.imagePath,
    required this.userId,
    required this.status,
    required this.missingDate,
    required this.lastKnownLocation,
    required this.contactInfo,
    this.rewardAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MissingCarModel.fromJson(Map<String, dynamic> json) {
    return MissingCarModel(
      id: json['id'] ?? 0,
      plateNumber: json['plate_number'] ?? '',
      chassisNumber: json['chassis_number'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['image_path'],
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? 'missing',
      missingDate: DateTime.parse(
        json['missing_date'] ?? DateTime.now().toIso8601String(),
      ),
      lastKnownLocation: json['last_known_location'] ?? '',
      contactInfo: json['contact_info'] ?? '',
      rewardAmount: json['reward_amount'],
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
      'id': id,
      'plate_number': plateNumber,
      'chassis_number': chassisNumber,
      'brand': brand,
      'model': model,
      'color': color,
      'description': description,
      'image_path': imagePath,
      'user_id': userId,
      'status': status,
      'missing_date': missingDate.toIso8601String(),
      'last_known_location': lastKnownLocation,
      'contact_info': contactInfo,
      'reward_amount': rewardAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullCarName => '$brand $model';

  String get formattedMissingDate {
    return '${missingDate.day}/${missingDate.month}/${missingDate.year}';
  }

  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  bool get hasReward => rewardAmount != null && rewardAmount!.isNotEmpty;

  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
}
