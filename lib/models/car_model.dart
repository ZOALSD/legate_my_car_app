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
    this.userId,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    print('imageUrl: ${json['imageUrl'] ?? ''}');
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
