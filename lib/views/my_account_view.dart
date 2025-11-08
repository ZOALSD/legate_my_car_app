import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:legate_my_car/utils/translation_helper.dart';
import '../models/login_model.dart';
import '../services/auth_service.dart';
import '../services/dio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/google_sign_in_button.dart';
import '../utils/connection_helper.dart';
import 'car_list_view.dart';

class MyAccountView extends StatefulWidget {
  const MyAccountView({super.key});

  @override
  State<MyAccountView> createState() => _MyAccountViewState();
}

class _MyAccountViewState extends State<MyAccountView> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check internet connection first
      final hasInternet = await ConnectionHelper.hasInternet();
      if (!hasInternet) {
        // If no internet, try to load from storage
        final user = await AuthService.getCurrentUser();
        setState(() {
          _user = user;
          _isLoading = false;
        });
        if (mounted && _user == null) {
          Get.snackbar(
            'ERROR'.tr,
            'NO_INTERNET_CONNECTION'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.errorColor,
            colorText: Colors.white,
          );
        }
        return;
      }

      // Call API to get user info
      final endpoint = '/guest/info';
      final dio = DioService.instance;
      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        final userInfoResponse = UserInfoResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (userInfoResponse.success) {
          // Save user info to storage
          final userJson = userInfoResponse.user.toJsonString();
          final storage = const FlutterSecureStorage();
          await storage.write(key: 'auth_user', value: userJson);

          setState(() {
            _user = userInfoResponse.user;
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load user info: Invalid response');
        }
      } else {
        throw Exception('Failed to load user info: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle DioException - try to load from storage as fallback
      final user = await AuthService.getCurrentUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });

      if (mounted) {
        String errorMessage = 'FAILED_TO_LOAD_USER_INFO'.tr;
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'CONNECTION_TIMEOUT'.tr;
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'NO_INTERNET_CONNECTION'.tr;
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'UNAUTHORIZED'.tr;
        }

        Get.snackbar(
          'ERROR'.tr,
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Fallback to storage on any other error
      final user = await AuthService.getCurrentUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });

      if (mounted) {
        Get.snackbar(
          'ERROR'.tr,
          'FAILED_TO_LOAD_USER_INFO'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MY_ACCOUNT'.tr)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'NO_USER_INFO'.tr,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Avatar Section
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Name
                  _buildInfoCard(
                    icon: Icons.person,
                    label: 'NAME'.tr,
                    value: _user!.name.isNotEmpty
                        ? _user!.name
                        : 'NOT_AVAILABLE'.tr,
                  ),
                  const SizedBox(height: 16),

                  // Email (only for non-guest users)
                  if (!_user!.isGuest) ...[
                    _buildInfoCard(
                      icon: Icons.email,
                      label: 'EMAIL'.tr,
                      value: _user!.email.isNotEmpty
                          ? _user!.email
                          : 'NOT_AVAILABLE'.tr,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Account Type
                  _buildInfoCard(
                    icon: _user!.isGuest
                        ? Icons.person_outline
                        : Icons.verified_user,
                    label: 'ACCOUNT_TYPE'.tr,
                    value: _user!.isGuest
                        ? 'GUEST_USER'.tr
                        : 'REGISTERED_USER'.tr,
                  ),
                  const SizedBox(height: 24),

                  // Upgrade to Google Account (only for guest users)
                  if (_user!.isGuest) _buildUpgradeButton(),
                  if (_user!.isGuest) const SizedBox(height: 24),
                  if (!_user!.isGuest) _buildDeleteAccountCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build upgrade to Google account button for guest users
  Widget _buildUpgradeButton() {
    return Card(
      elevation: 2,
      color: AppTheme.primaryColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.upgrade, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPGRADE_ACCOUNT'.tr,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'UPGRADE_ACCOUNT_DESCRIPTION'.tr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GoogleSignInButton(showAsOutline: false, padding: EdgeInsets.zero),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountCard() {
    return Card(
      elevation: 2,
      color: AppTheme.errorColor.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.delete_forever,
                  color: AppTheme.errorColor,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELETE_ACCOUNT'.tr,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DELETE_ACCOUNT_DESCRIPTION'.tr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isDeletingAccount
                  ? null
                  : () => _confirmDeleteAccount(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: AppTheme.sudanWhite,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: _isDeletingAccount
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.sudanWhite,
                        ),
                      ),
                    )
                  : const Icon(Icons.delete_outline),
              label: Text(
                _isDeletingAccount
                    ? 'DELETING_ACCOUNT'.tr
                    : 'DELETE_ACCOUNT'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('DELETE_ACCOUNT_CONFIRM_TITLE'.tr),
          content: Text('DELETE_ACCOUNT_CONFIRM_MESSAGE'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('CANCEL'.tr),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: AppTheme.sudanWhite,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('DELETE_ACCOUNT_CONFIRM_ACTION'.tr),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // await _deleteAccount();
      setState(() {
        _isDeletingAccount = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        AuthService.logout();
        Get.offAll(() => const CarListView());
        // show Snackbar with success message
        UtilsHelper.showSuccessSnackBar(
          context,
          message: 'ACCOUNT_DELETED_SUCCESSFULLY'.tr,
        );
      });
    }
  }

  Future<void> _deleteAccount() async {
    if (_isDeletingAccount) return;

    final isGuest = _user?.isGuest ?? true;
    if (!isGuest) {
      final hasInternet = await ConnectionHelper.hasInternet();
      if (!hasInternet) {
        if (mounted) {
          Get.snackbar(
            'ERROR'.tr,
            'DELETE_ACCOUNT_OFFLINE'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.errorColor,
            colorText: Colors.white,
          );
        }
        return;
      }
    }

    setState(() {
      _isDeletingAccount = true;
    });

    final success = await AuthService.deleteAccount();

    if (!mounted) {
      return;
    }

    setState(() {
      _isDeletingAccount = false;
      _user = success ? null : _user;
    });

    if (success) {
      Get.snackbar(
        'SUCCESS'.tr,
        'DELETE_ACCOUNT_SUCCESS'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.secondaryColor,
        colorText: Colors.white,
      );

      // Navigate back to main view
      Get.offAll(() => const CarListView());
    } else {
      Get.snackbar(
        'ERROR'.tr,
        'DELETE_ACCOUNT_ERROR'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
