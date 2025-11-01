import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/login_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class MyAccountView extends StatefulWidget {
  const MyAccountView({super.key});

  @override
  State<MyAccountView> createState() => _MyAccountViewState();
}

class _MyAccountViewState extends State<MyAccountView> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
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

                  // Email
                  _buildInfoCard(
                    icon: Icons.email,
                    label: 'EMAIL'.tr,
                    value: _user!.email.isNotEmpty
                        ? _user!.email
                        : 'NOT_AVAILABLE'.tr,
                  ),
                  const SizedBox(height: 16),

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
}
