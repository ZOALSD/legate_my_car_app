import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:legate_my_car/theme/app_theme.dart';
import 'package:legate_my_car/views/car_list_view.dart';
import 'package:legate_my_car/views/login_view.dart';
import '../services/auth_service.dart';
import '../utils/connection_helper.dart';

class IntroView extends StatefulWidget {
  const IntroView({super.key});

  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> {
  bool isLoading = true;
  bool isAuthenticated = false;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      hasInternet = await ConnectionHelper.hasInternet();
      if (hasInternet) {
        final hasToken = await AuthService.isAuthenticated();

        if (hasToken) {
          isAuthenticated = true;
        } else {
          // Show login view instead of auto-logging as guest
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            await Future.delayed(const Duration(milliseconds: 500));
            _redirectToLoginView();
          }
          return;
        }
      } else {
        setState(() {
          isLoading = false;
          hasInternet = false;
        });
      }

      if (isAuthenticated && mounted) {
        _redirectToCarListView();
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _redirectToLoginView();
      }
    }
  }

  void _redirectToCarListView() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CarListView()),
      );
    }
  }

  void _redirectToLoginView() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/logo.svg', width: 200, height: 200),
            const SizedBox(height: 15),
            Text(
              "APP_TITLE".tr,
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _loadingIndicatorOrNoInternetMessage(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _loadingIndicatorOrNoInternetMessage() {
    if (isLoading) {
      return const CircularProgressIndicator();
    } else if (!hasInternet) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Text(
                "NO_INTERNET_CONNECTION".tr,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _initializeApp();
                },
                child: Text("TRY_AGAIN".tr),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
