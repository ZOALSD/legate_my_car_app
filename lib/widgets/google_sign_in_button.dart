import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../views/car_list_view.dart';
import '../utils/translation_helper.dart';

/// A reusable Google Sign-In button widget
class GoogleSignInButton extends StatefulWidget {
  final bool showAsOutline;
  final EdgeInsets? padding;

  const GoogleSignInButton({
    super.key,
    this.showAsOutline = false,
    this.padding,
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
      final success = await AuthService.signInWithGoogle();

      if (mounted) {
        if (success) {
          // Navigate to main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CarListView()),
          );

          // Show success message
          TranslationHelper.showSuccessSnackBar(
            context,
            message: 'SIGN_IN_SUCCESS'.tr,
          );
        } else {
          // Show error message
          TranslationHelper.showErrorSnackBar(
            context,
            message: 'GOOGLE_SIGN_IN_ERROR'.tr,
            title: 'SIGN_IN_ERROR'.tr,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        TranslationHelper.showErrorSnackBar(
          context,
          message: e.toString(),
          title: 'SIGN_IN_ERROR'.tr,
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
}
