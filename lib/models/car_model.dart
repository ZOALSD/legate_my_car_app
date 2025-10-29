class CarModel {
  final String id;
  final String? plateNumber;
  final String? chassisNumber;
  final String? brand;
  final String? model;
  final String? color;
  final String? description;
  final String? imagePath;
  final String? imageUrl;
  final int userId;
  final String status;
  final DateTime? lostDate;
  final String? location;
  final String? latitude;
  final String? longitude;
  final String? phoneNumber;
  final int? carNumber;
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
    this.imageUrl,
    required this.userId,
    required this.status,
    required this.lostDate,
    required this.location,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.carNumber,
    this.contactInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id']?.toString() ?? '',
      plateNumber: json['plate_number'] ?? '',
      chassisNumber: json['chassis_number'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['image_path'],
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? '',
      lostDate: json['lost_date'] != null
          ? DateTime.parse(json['lost_date'])
          : null,
      location: json['location'] ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      phoneNumber: json['phone_number'],
      carNumber: json['car_number'],
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
      'image_url': imageUrl,
      'user_id': userId,
      'status': status,
      'lost_date': lostDate?.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'car_number': carNumber,
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
    // First try imageUrl if available
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl;
    }

    // Fallback to imagePath
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
