import 'package:get/get.dart';
import '../models/missing_car_model.dart';

class MissingCarViewModel extends GetxController {
  // Observable variables
  var missingCars = <MissingCarModel>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'all'.obs;

  // Status options
  final List<String> statusOptions = ['all', 'missing', 'found', 'recovered'];

  @override
  void onInit() {
    super.onInit();
    loadMissingCars();
  }

  // Load missing cars from API
  Future<void> loadMissingCars() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Simulate API call - replace with actual API endpoint
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      final mockData = [
        {
          'id': 1,
          'plate_number': 'KRT-1234',
          'chassis_number': 'ABC123456789',
          'brand': 'Toyota',
          'model': 'Corolla',
          'color': 'White',
          'description': 'My car was stolen from my house in Khartoum',
          'image_path': null,
          'user_id': 1,
          'status': 'missing',
          'missing_date': '2024-01-15T00:00:00.000Z',
          'last_known_location': 'Khartoum, Al-Riyadh',
          'contact_info': '+249912345678',
          'reward_amount': '5000 SDG',
          'created_at': '2024-01-15T10:00:00.000Z',
          'updated_at': '2024-01-15T10:00:00.000Z',
        },
        {
          'id': 2,
          'plate_number': 'KRT-5678',
          'chassis_number': 'DEF987654321',
          'brand': 'Honda',
          'model': 'Civic',
          'color': 'Black',
          'description': 'Car was taken during the conflict',
          'image_path': null,
          'user_id': 2,
          'status': 'missing',
          'missing_date': '2024-01-20T00:00:00.000Z',
          'last_known_location': 'Omdurman, Al-Thawra',
          'contact_info': '+249987654321',
          'reward_amount': '3000 SDG',
          'created_at': '2024-01-20T14:30:00.000Z',
          'updated_at': '2024-01-20T14:30:00.000Z',
        },
      ];

      missingCars.value = mockData
          .map((json) => MissingCarModel.fromJson(json))
          .toList();
    } catch (e) {
      error.value = 'Failed to load missing cars: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Search missing cars
  void searchMissingCars(String query) {
    searchQuery.value = query;
    // In a real app, this would filter the results
    // For now, we'll just update the search query
  }

  // Filter by status
  void filterByStatus(String status) {
    selectedStatus.value = status;
    // In a real app, this would filter the results
  }

  // Get filtered missing cars
  List<MissingCarModel> get filteredMissingCars {
    var filtered = missingCars;

    // Filter by status
    if (selectedStatus.value != 'all') {
      filtered = filtered
          .where((car) => car.status == selectedStatus.value)
          .toList()
          .obs;
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered
          .where((car) {
            return car.plateNumber.toLowerCase().contains(query) ||
                car.brand.toLowerCase().contains(query) ||
                car.model.toLowerCase().contains(query) ||
                car.color.toLowerCase().contains(query) ||
                car.lastKnownLocation.toLowerCase().contains(query);
          })
          .toList()
          .obs;
    }

    return filtered;
  }

  // Report a missing car
  Future<bool> reportMissingCar({
    required String plateNumber,
    required String chassisNumber,
    required String brand,
    required String model,
    required String color,
    required String description,
    required String lastKnownLocation,
    required String contactInfo,
    String? rewardAmount,
    String? imagePath,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Create new missing car model
      final newCar = MissingCarModel(
        id: missingCars.length + 1,
        plateNumber: plateNumber,
        chassisNumber: chassisNumber,
        brand: brand,
        model: model,
        color: color,
        description: description,
        imagePath: imagePath,
        userId: 1, // In real app, get from user session
        status: 'missing',
        missingDate: DateTime.now(),
        lastKnownLocation: lastKnownLocation,
        contactInfo: contactInfo,
        rewardAmount: rewardAmount,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to list
      missingCars.add(newCar);

      return true;
    } catch (e) {
      error.value = 'Failed to report missing car: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Contact owner
  void contactOwner(MissingCarModel car) {
    // In a real app, this would open contact options
    // For now, just show a message
    Get.snackbar(
      'Contact Owner',
      'Contact: ${car.contactInfo}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  // Refresh data
  @override
  Future<void> refresh() async {
    await loadMissingCars();
  }
}
