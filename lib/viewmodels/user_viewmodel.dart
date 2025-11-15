import 'package:get/get.dart';
import 'package:legate_my_car/models/enums/account_type.dart';
import 'package:legate_my_car/models/enums/user_status.dart';
import 'package:legate_my_car/models/user_model.dart';
import 'package:legate_my_car/services/user_api_service.dart';

class UserViewModel extends GetxController {
  static UserViewModel get instance {
    if (Get.isRegistered<UserViewModel>()) {
      return Get.find<UserViewModel>();
    }
    return Get.put(UserViewModel());
  }

  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalUsers = 0.obs;
  final RxBool _hasMorePages = false.obs;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalUsers => _totalUsers.value;
  bool get hasMorePages => _hasMorePages.value;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers({int page = 1, bool append = false}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await UserApiService.getUsers(page: page, perPage: 10);

      if (!response.success) {
        _errorMessage.value = 'FAILED_TO_LOAD_USERS'.tr;
        _users.value = [];
        _currentPage.value = 1;
        _totalPages.value = 1;
        _totalUsers.value = 0;
        _hasMorePages.value = false;
        return;
      }

      if (append && page > 1) {
        _users.addAll(response.data ?? []);
      } else {
        _users.value = response.data ?? [];
      }

      _currentPage.value = response.pagination?.currentPage ?? 1;
      _totalPages.value = response.pagination?.lastPage ?? 1;
      _totalUsers.value = response.pagination?.total ?? _users.length;
      _hasMorePages.value = response.pagination?.hasMorePages ?? false;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _users.value = [];
      _currentPage.value = 1;
      _totalPages.value = 1;
      _totalUsers.value = 0;
      _hasMorePages.value = false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadNextPage() async {
    if (_hasMorePages.value && !_isLoading.value) {
      await loadUsers(page: _currentPage.value + 1, append: true);
    }
  }

  Future<void> loadPreviousPage() async {
    if (_currentPage.value > 1 && !_isLoading.value) {
      await loadUsers(page: _currentPage.value - 1);
    }
  }

  @override
  Future<void> refresh() async {
    await loadUsers(page: 1);
  }

  UserModel? getUserById(int id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> updateUser({
    required int id,
    required String name,
    required String email,
    required UserStatus status,
    required AccountType accountType,
  }) async {
    try {
      final updatedUser = await UserApiService.updateUser(
        id: id,
        name: name,
        email: email,
        status: status.name,
        accountType: accountType.name,
      );

      final index = _users.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }

      return updatedUser;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    }
  }
}
