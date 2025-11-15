import 'package:get/get.dart';
import 'package:legate_my_car/models/api_response_model.dart';
import 'package:legate_my_car/models/lost_car_model.dart';
import '../services/lost_car_request_service.dart';
import '../services/auth_service.dart';

class MissingCarViewModel extends GetxController {
  // Observable variables
  var missingCars = <LostCarModel>[].obs;
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
      final ListResponseModel<LostCarModel> listResponse =
          await LostCarRequestService.getLostCarRequests(
            page: page,
            perPage: 10,
          );

      if (append && page > 1) {
        missingCars.addAll(listResponse.data ?? []);
      } else {
        missingCars.value = listResponse.data ?? [];
      }

      // Update pagination info
      currentPage.value = listResponse.pagination?.currentPage ?? 1;
      totalPages.value = listResponse.pagination?.lastPage ?? 1;
      totalCars.value = listResponse.pagination?.total ?? 0;
      hasMorePages.value = listResponse.pagination?.hasMorePages ?? false;
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

  // Create a new lost car request
  Future<bool> createLostCarRequest({required LostCarModel lostCar}) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Call API to create lost car request
      final createdLostCar = await LostCarRequestService.createLostCarRequest(
        lostCar: lostCar,
      );

      missingCars.value = [createdLostCar, ...missingCars];
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

  Future<bool> updateLostCarRequest({required LostCarModel lostCar}) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Call API to create lost car request
      final updatedLostCar = await LostCarRequestService.updateLostCarRequest(
        lostCar: lostCar,
      );

      missingCars.value = missingCars
          .map((car) => car.id == updatedLostCar.id ? updatedLostCar : car)
          .toList();
      return true;
    } catch (e) {
      // Extract error message, removing "Exception: " prefix if present
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      error.value = 'Failed to create lost car request: $errorMsg';
      throw Exception(errorMsg);
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
