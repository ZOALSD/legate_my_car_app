import 'package:get/get.dart';
import '../models/car_model.dart';
import '../services/api_service.dart';

class CarViewModel extends GetxController {
  static CarViewModel get instance {
    if (Get.isRegistered<CarViewModel>()) {
      return Get.find<CarViewModel>();
    } else {
      return Get.put(CarViewModel());
    }
  }

  // Observable variables
  final RxList<CarModel> _cars = <CarModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedStatus = 'all'.obs;
  final RxString _errorMessage = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalCars = 0.obs;
  final RxBool _hasMorePages = false.obs;

  // Getters
  List<CarModel> get cars => _cars;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get selectedStatus => _selectedStatus.value;
  String get errorMessage => _errorMessage.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalCars => _totalCars.value;
  bool get hasMorePages => _hasMorePages.value;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await loadCars();
  }

  // Load all cars
  Future<void> loadCars({
    int page = 1,
    bool append = false,
    String? chassisNumber,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await ApiService.getAllCars(
        page: page,
        perPage: 10,
        chassisNumber: chassisNumber,
      );

      if (append && page > 1) {
        _cars.addAll(response.cars);
      } else {
        _cars.value = response.cars;
      }

      _currentPage.value = response.pagination.currentPage;
      _totalPages.value = response.pagination.lastPage;
      _totalCars.value = response.pagination.total;
      _hasMorePages.value = response.pagination.hasMorePages;
    } catch (e) {
      _errorMessage.value = e.toString();
      _cars.value = [];
      _currentPage.value = 1;
      _totalPages.value = 1;
      _totalCars.value = 0;
      _hasMorePages.value = false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Search cars
  Future<void> searchCars(String query) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _searchQuery.value = query;
    _currentPage.value = 1;
    await loadCars(page: 1, chassisNumber: query);
  }

  // Filter by status
  Future<void> filterByStatus(String status) async {
    _selectedStatus.value = status;
    _currentPage.value = 1;
    await loadCars(page: 1);
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (_hasMorePages.value && !_isLoading.value) {
      await loadCars(page: _currentPage.value + 1, append: true);
    }
  }

  // Load previous page
  Future<void> loadPreviousPage() async {
    if (_currentPage.value > 1 && !_isLoading.value) {
      await loadCars(page: _currentPage.value - 1);
    }
  }

  // Clear search
  Future<void> clearSearch() async {
    _searchQuery.value = '';
    _currentPage.value = 1;
    await loadCars(page: 1);
  }

  // Refresh data
  @override
  Future<void> refresh() async {
    _currentPage.value = 1;
    await loadCars(page: 1);
  }

  // Get car by ID
  CarModel? getCarById(int id) {
    try {
      return _cars.firstWhere((car) => car.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get status counts
  Map<String, int> getStatusCounts() {
    final counts = <String, int>{};
    for (final car in _cars) {
      counts[car.status] = (counts[car.status] ?? 0) + 1;
    }
    return counts;
  }
}
