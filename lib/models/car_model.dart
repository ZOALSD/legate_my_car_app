class CarModel {
  final int id;
  final String plateNumber;
  final String chassisNumber;
  final String? brand;
  final String? model;
  final String? color;
  final String? description;
  final String? imagePath;
  final int userId;
  final String status;
  final DateTime? lostDate;
  final String? location;
  final String? contactInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  CarModel({
    required this.id,
    required this.plateNumber,
    required this.chassisNumber,
    required this.brand,
    required this.model,
    required this.color,
    required this.description,
    this.imagePath,
    required this.userId,
    required this.status,
    required this.lostDate,
    required this.location,
    this.contactInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] ?? 0,
      plateNumber: json['plate_number'] ?? '',
      chassisNumber: json['chassis_number'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['image_path'],
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? '',
      lostDate: DateTime.parse(
        json['lost_date'] ?? DateTime.now().toIso8601String(),
      ),
      location: json['location'] ?? '',
      contactInfo: json['contact_info'],
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
      'lost_date': lostDate?.toIso8601String(),
      'location': location,
      'contact_info': contactInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullCarName => '$brand $model';

  String get formattedLostDate {
    return '${lostDate?.day}/${lostDate?.month}/${lostDate?.year}';
  }

  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get full image URL
  String? get fullImageUrl {
    if (imagePath == null || imagePath!.isEmpty) {
      return null;
    }
    // If already a full URL, return as is
    if (imagePath!.startsWith('http://') || imagePath!.startsWith('https://')) {
      return imagePath;
    }
    // Otherwise, prepend the base URL
    return 'https://api.laqeetarabeety.com/storage/$imagePath';
  }

  @override
  String toString() {
    return 'CarModel(id: $id, plateNumber: $plateNumber, brand: $brand, model: $model, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
