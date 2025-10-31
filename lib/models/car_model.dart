class CarModel {
  final String? id;
  final String? plateNumber;
  final String? chassisNumber;
  final String? brand;
  final String? model;
  final String? color;
  final String? description;
  final String? imageUrl;
  final int? userId;
  final String? status;
  final DateTime? lostDate;
  final String? location;
  final String? latitude;
  final String? longitude;
  final String? phoneNumber;
  final int? carNumber;
  final String? contactInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CarModel({
    this.id,
    required this.plateNumber,
    required this.chassisNumber,
    required this.brand,
    required this.model,
    required this.description,
    this.color,
    this.imageUrl,
    this.userId,
    this.status,
    this.lostDate,
    this.location,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.carNumber,
    this.contactInfo,
    this.createdAt,
    this.updatedAt,
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
      imageUrl: json['image_url'],
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
      'status': "lost",
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullCarName => '$brand $model';

  String get formattedLostDate {
    return '${lostDate?.day}/${lostDate?.month}/${lostDate?.year}';
  }

  String get formattedCreatedDate {
    return '${createdAt?.day}/${createdAt?.month}/${createdAt?.year}';
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
