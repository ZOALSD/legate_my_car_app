import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:legate_my_car/models/enums/user_status.dart';
import 'package:legate_my_car/models/login_response.dart';
import '../config/app_flavor.dart';
import '../theme/app_theme.dart';
import '../utils/connection_helper.dart';
import '../utils/translation_helper.dart';
import '../views/car_list_view.dart';
import '../widgets/google_sign_in_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              // App Logo
              SvgPicture.asset(
                AppFlavorConfig.logoPath,
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
                onResult: _handleSignInResult,
                onInactiveStatus: _handleAccountInactive,
                onError: _handleSignInError,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignInResult(LoginResponse response) {
    if (!mounted) return;

    if (response.success) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.offAll(() => const CarListView());
      UtilsHelper.showSuccessSnackBar(context, message: 'SIGN_IN_SUCCESS'.tr);
    } else if (response.isInactive && response.inactiveStatus != null) {
      _handleAccountInactive(response.inactiveStatus!);
    } else {
      UtilsHelper.showErrorSnackBar(
        context,
        message: _translateMessage(response.message),
        title: 'SIGN_IN_ERROR'.tr,
      );
    }
  }

  void _handleAccountInactive(UserStatus status) {
    final statusLabel = 'USER_STATUS_${status.name.toUpperCase()}'.tr;
    Get.dialog(
      AlertDialog(
        title: Text('ACCOUNT_INACTIVE_TITLE'.tr),
        content: Text(
          'ACCOUNT_INACTIVE_MESSAGE'.trParams({'status': statusLabel}),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('OK'.tr)),
        ],
      ),
    );
  }

  void _handleSignInError(Object error) {
    if (!mounted) return;
    UtilsHelper.showErrorSnackBar(
      context,
      message: 'GOOGLE_SIGN_IN_ERROR'.tr,
      title: 'GOOGLE_SIGN_IN_ERROR'.tr,
    );
  }

  String _translateMessage(String? message) {
    if (message == null || message.isEmpty) {
      return 'GOOGLE_SIGN_IN_ERROR'.tr;
    }
    final translated = message.tr;
    return translated.isEmpty ? message : translated;
  }
}
