class CarModel {
  final String? id;
  final int? number;
  final String? carName;
  final String? plateNumber;
  final String? chassisNumber;
  final String? modelYear;
  final String? description;
  final String? location;
  final String? latitude;
  final String? longitude;
  final String? imagePath;
  final String? imageUrl;
  final UserModelShortInfo? user;
  final int? userId;

  CarModel({
    this.id,
    this.number,
    this.carName,
    this.plateNumber,
    this.chassisNumber,
    this.modelYear,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.imagePath,
    this.imageUrl,
    this.user,
    this.userId,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] ?? '',
      number: json['number'] ?? -1, // -1 means not set
      carName: json['carName'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      chassisNumber: json['chassisNumber'] ?? '',
      modelYear: json['modelYear'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      imagePath: json['imagePath'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      userId: json['userId'] ?? -1, // -1 means not set
      user: json.containsKey('user') && json['user'] != null
          ? UserModelShortInfo.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'carName': carName,
      'plateNumber': plateNumber,
      'chassisNumber': chassisNumber,
      'modelYear': modelYear,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'description': description,
    };
  }
}

class UserModelShortInfo {
  final int id;
  final String name;
  final String email;

  UserModelShortInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModelShortInfo.fromJson(Map<String, dynamic> json) {
    return UserModelShortInfo(
      id: json['id'] ?? -1,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
