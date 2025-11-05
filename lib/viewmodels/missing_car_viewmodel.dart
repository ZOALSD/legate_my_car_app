import 'dart:io';
import 'package:get/get.dart';
import '../models/missing_car_model.dart';
import '../services/lost_car_request_service.dart';
import '../services/auth_service.dart';

class MissingCarViewModel extends GetxController {
  // Observable variables
  var missingCars = <MissingCarModel>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'all'.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalCars = 0.obs;
  var hasMorePages = false.obs;

  // Guest check variables
  var isCheckingGuest = true.obs;
  var isGuest = false.obs;

  // Status options
  final List<String> statusOptions = ['all', 'missing', 'found', 'recovered'];

  @override
  void onInit() {
    super.onInit();
    checkIfGuest();
  }

  /// Check if current user is a guest
  Future<void> checkIfGuest() async {
    try {
      isCheckingGuest.value = true;
      final user = await AuthService.getCurrentUser();

      // If user is null or is a guest, mark as guest
      if (user == null || user.isGuest) {
        isGuest.value = true;
        isCheckingGuest.value = false;
      } else {
        isGuest.value = false;
        isCheckingGuest.value = false;
        // Only load data if user is not a guest
        await loadMissingCars();
      }
    } catch (e) {
      // On error, treat as guest for safety
      isGuest.value = true;
      isCheckingGuest.value = false;
    }
  }

  /// Refresh guest check (useful after login)
  Future<void> refreshGuestCheck() async {
    await checkIfGuest();
  }

  // Load missing cars from API
  Future<void> loadMissingCars({int page = 1, bool append = false}) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Call API to get lost car requests
      final response = await LostCarRequestService.getLostCarRequests(
        page: page,
        perPage: 10,
      );

      // Convert LostCarRequestModel to MissingCarModel
      final convertedCars = response.requests
          .map((request) => request.toMissingCarModel())
          .toList();

      if (append && page > 1) {
        missingCars.addAll(convertedCars);
      } else {
        missingCars.value = convertedCars;
      }

      // Update pagination info
      currentPage.value = response.pagination.currentPage;
      totalPages.value = response.pagination.lastPage;
      totalCars.value = response.pagination.total;
      hasMorePages.value = response.pagination.hasMorePages;
    } catch (e) {
      // Extract error message, removing "Exception: " prefix if present
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      error.value = errorMsg;
      if (!append) {
        missingCars.value = [];
      }
      currentPage.value = 1;
      totalPages.value = 1;
      totalCars.value = 0;
      hasMorePages.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (hasMorePages.value && !isLoading.value) {
      await loadMissingCars(page: currentPage.value + 1, append: true);
    }
  }

  // Search missing cars
  void searchMissingCars(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadMissingCars(page: 1, append: false);
  }

  // Filter by status
  void filterByStatus(String status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    loadMissingCars(page: 1, append: false);
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
  // Returns the contact info - snackbar handling should be done in the view
  String contactOwner(MissingCarModel car) {
    // In a real app, this would open contact options
    // For now, just return the contact info
    return car.contactInfo;
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  // Update missing car
  Future<bool> updateMissingCar({
    required int carId,
    required String plateNumber,
    required String chassisNumber,
    required String brand,
    required String model,
    required String color,
    required String description,
    required String lastKnownLocation,
    required String contactInfo,
    required String status,
    String? rewardAmount,
    File? imageFile,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Find the car in the list
      final index = missingCars.indexWhere((car) => car.id == carId);
      if (index == -1) {
        error.value = 'Car not found';
        return false;
      }

      final car = missingCars[index];

      // Check if we have the original request ID (UUID)
      if (car.originalRequestId == null || car.originalRequestId!.isEmpty) {
        error.value = 'Cannot update: Original request ID not found';
        return false;
      }

      // Call API to update lost car request
      // Note: API only accepts: chassis_number, plate_number, model, color, last_known_location
      final updatedRequest = await LostCarRequestService.updateLostCarRequest(
        id: car.originalRequestId!,
        chassisNumber: chassisNumber,
        plateNumber: plateNumber,
        model: model,
        color: color,
        lastKnownLocation: lastKnownLocation,
      );

      // Convert updated request back to MissingCarModel
      final updatedCar = updatedRequest.toMissingCarModel();

      // Preserve local-only fields that aren't in the API response
      final finalUpdatedCar = MissingCarModel(
        id: updatedCar.id,
        originalRequestId: updatedRequest.id, // Keep the UUID
        plateNumber: updatedCar.plateNumber,
        chassisNumber: updatedCar.chassisNumber,
        brand: car.brand, // Not in API, keep original
        model: updatedCar.model,
        color: updatedCar.color,
        description: car.description, // Not in API, keep original
        imagePath: imageFile?.path ?? car.imagePath,
        userId: car.userId,
        status: car.status, // Not in API response, keep original
        missingDate: car.missingDate,
        lastKnownLocation: updatedCar.lastKnownLocation,
        contactInfo: car.contactInfo, // Not in API, keep original
        rewardAmount: car.rewardAmount, // Not in API, keep original
        createdAt: car.createdAt,
        updatedAt: updatedCar.updatedAt,
      );

      // Update in list
      missingCars[index] = finalUpdatedCar;

      return true;
    } catch (e) {
      // Extract error message, removing "Exception: " prefix if present
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      error.value = 'Failed to update missing car: $errorMsg';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new lost car request
  Future<bool> createLostCarRequest({
    required String plateNumber,
    required String chassisNumber,
    required String model,
    required String color,
    required String lastKnownLocation,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Call API to create lost car request
      final createdRequest = await LostCarRequestService.createLostCarRequest(
        chassisNumber: chassisNumber,
        plateNumber: plateNumber,
        model: model,
        color: color,
        lastKnownLocation: lastKnownLocation,
      );

      // Convert created request to MissingCarModel and add to list
      final newCar = createdRequest.toMissingCarModel();
      missingCars.insert(0, newCar); // Add to beginning of list

      // Update total count
      totalCars.value = totalCars.value + 1;

      return true;
    } catch (e) {
      // Extract error message, removing "Exception: " prefix if present
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      error.value = 'Failed to create lost car request: $errorMsg';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  @override
  Future<void> refresh() async {
    await loadMissingCars(page: 1, append: false);
  }
}
