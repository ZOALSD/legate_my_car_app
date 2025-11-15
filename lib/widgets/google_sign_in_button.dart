import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legate_my_car/models/enums/user_status.dart';
import 'package:legate_my_car/models/login_response.dart';
import 'package:legate_my_car/views/my_lost_cars_view.dart';
import '../services/auth_service.dart';
import '../views/car_list_view.dart';
import '../utils/translation_helper.dart';

/// A reusable Google Sign-In button widget
class GoogleSignInButton extends StatefulWidget {
  final bool showAsOutline;
  final EdgeInsets? padding;
  final bool redirectToMyLostCars;
  final ValueChanged<LoginResponse>? onResult;
  final ValueChanged<UserStatus>? onInactiveStatus;
  final ValueChanged<Object>? onError;

  const GoogleSignInButton({
    super.key,
    this.showAsOutline = false,
    this.redirectToMyLostCars = false,
    this.padding,
    this.onResult,
    this.onInactiveStatus,
    this.onError,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.signInWithGoogle();
      if (widget.onResult != null) {
        widget.onResult!(response);
        return;
      }

      if (!mounted) return;

      if (response.success) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        if (widget.redirectToMyLostCars) {
          Get.offAll(() => const MyLostCarsView());
        } else {
          Get.offAll(() => const CarListView());
        }

        UtilsHelper.showSuccessSnackBar(context, message: 'SIGN_IN_SUCCESS'.tr);
      } else if (response.isInactive) {
        _showInactiveDialog(response.inactiveStatus!);
      } else {
        UtilsHelper.showErrorSnackBar(
          context,
          message: response.message?.tr ?? 'GOOGLE_SIGN_IN_ERROR'.tr,
          title: 'SIGN_IN_ERROR'.tr,
        );
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!(e);
        return;
      }

      if (!mounted) return;

      UtilsHelper.showErrorSnackBar(
        context,
        message: 'GOOGLE_SIGN_IN_ERROR'.tr,
        title: 'GOOGLE_SIGN_IN_ERROR'.tr,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
      child: widget.showAsOutline
          ? OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Image.asset(
                      'assets/images/google_logo.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if Google logo asset doesn't exist
                        return const Icon(Icons.login, size: 20);
                      },
                    ),
              label: Text(
                _isLoading ? 'SIGNING_IN'.tr : 'SIGN_IN_WITH_GOOGLE'.tr,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          : ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Image.asset(
                      'assets/images/google_logo.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if Google logo asset doesn't exist
                        return const Icon(Icons.login, size: 20);
                      },
                    ),
              label: Text(
                _isLoading ? 'SIGNING_IN'.tr : 'SIGN_IN_WITH_GOOGLE'.tr,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
    );
  }

  void _showInactiveDialog(UserStatus status) {
    if (widget.onInactiveStatus != null) {
      widget.onInactiveStatus!(status);
      return;
    }

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
}
