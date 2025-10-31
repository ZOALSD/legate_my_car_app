import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../utils/connection_helper.dart';
import '../widgets/google_sign_in_button.dart';
import '../theme/app_theme.dart';
import 'car_list_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isLoading = false;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    final hasInternet = await ConnectionHelper.hasInternet();
    setState(() {
      _hasInternet = hasInternet;
    });
  }

  Future<void> _handleGuestLogin() async {
    if (_isLoading || !_hasInternet) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.loginAsGuest();

      if (mounted) {
        if (success) {
          _navigateToMainScreen();
        } else {
          Get.snackbar(
            'SIGN_IN_ERROR'.tr,
            'NO_INTERNET_CONNECTION'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'SIGN_IN_ERROR'.tr,
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToMainScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CarListView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Get.locale?.languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // App Logo
              SvgPicture.asset(
                'assets/images/logo.svg',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),
              // App Title
              Text(
                "APP_TITLE".tr,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // App Subtitle
              Text(
                "APP_SUBTITLE".tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Internet Connection Status
              if (!_hasInternet)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "NO_INTERNET_CONNECTION".tr,
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              // Google Sign-In Button
              GoogleSignInButton(
                showAsOutline: false,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      isRTL ? 'أو' : 'OR',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 16),
              // Guest Login Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading || !_hasInternet
                      ? null
                      : _handleGuestLogin,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                  label: Text(
                    _isLoading ? 'SIGNING_IN'.tr : 'CONTINUE_AS_GUEST'.tr,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(
                      color: _isLoading || !_hasInternet
                          ? Colors.grey.shade300
                          : AppTheme.primaryColor,
                    ),
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Info Text
              Text(
                isRTL
                    ? 'يمكنك المتابعة كضيف للاستمرار بدون حساب'
                    : 'You can continue as guest to proceed without an account',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
