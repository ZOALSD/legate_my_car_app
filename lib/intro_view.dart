import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:legate_my_car/theme/app_theme.dart';
import 'package:legate_my_car/views/car_list_view.dart';
import 'package:legate_my_car/views/login_view.dart';
import 'package:legate_my_car/views/launcher_view.dart';
import '../services/auth_service.dart';
import '../services/local_preferences_service.dart';
import '../utils/connection_helper.dart';
import '../config/app_flavor.dart';

class IntroView extends StatefulWidget {
  const IntroView({super.key});

  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> {
  bool _isLoading = true;
  bool _hasInternet = true;
  bool _showLauncher = false;

  @override
  void initState() {
    super.initState();
    _checkLauncherStatus();
  }

  /// Check if launcher screen should be shown
  Future<void> _checkLauncherStatus() async {
    try {
      final hasSeenLauncher = await LocalPreferencesService.hasSeenLauncher();

      if (!hasSeenLauncher) {
        // Show launcher screen for first-time users
        setState(() {
          _showLauncher = true;
          _isLoading = false;
        });
      } else {
        // Skip launcher and proceed with app initialization
        _initializeApp();
      }
    } catch (e) {
      // If error, proceed with normal initialization
      _initializeApp();
    }
  }

  /// Mark launcher as seen and proceed with app initialization
  Future<void> _onLauncherComplete() async {
    try {
      await LocalPreferencesService.setHasSeenLauncher(true);
    } catch (e) {
      // Continue even if saving fails
    }
    _initializeApp();
  }

  /// Main initialization logic for the app
  Future<void> _initializeApp() async {
    try {
      // Check internet connectivity first
      _hasInternet = await _checkInternetConnection();

      if (!_hasInternet) {
        _stopLoading();
        return;
      }

      // Check if user is already authenticated
      final isAuthenticated = await AuthService.hasValidTokenStored();

      if (isAuthenticated) {
        _navigateToCarList();
        return;
      }

      // Handle unauthenticated users based on flavor
      await _handleUnauthenticatedUser();
    } catch (e) {
      _handleInitializationError();
    }
  }

  /// Check internet connectivity
  Future<bool> _checkInternetConnection() async {
    return await ConnectionHelper.hasInternet();
  }

  /// Handle unauthenticated users
  Future<void> _handleUnauthenticatedUser() async {
    _stopLoading();

    if (AppFlavorConfig.isManagers) {
      // Managers flavor: show login screen
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToLogin();
    } else {
      // Clients flavor: attempt guest login
      await _attemptGuestLogin();
    }
  }

  /// Attempt to log in as guest user
  Future<void> _attemptGuestLogin() async {
    final loginSuccess = await AuthService.loginAsGuest();

    if (loginSuccess && mounted) {
      _navigateToCarList();
    }
  }

  /// Handle errors during initialization
  Future<void> _handleInitializationError() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      _navigateToLogin();
    }
  }

  /// Stop the loading indicator
  void _stopLoading() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Navigate to car list view
  void _navigateToCarList() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CarListView()),
      );
    }
  }

  /// Navigate to login view
  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show launcher screen if it's the first time
    if (_showLauncher) {
      return LauncherView(onComplete: _onLauncherComplete);
    }

    return Scaffold(body: _buildBody());
  }

  /// Build the main body content
  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLogo(),
          const SizedBox(height: 15),
          _buildAppTitle(),
          const SizedBox(height: 20),
          _buildStatusWidget(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Build the app logo
  Widget _buildLogo() {
    return SvgPicture.asset(AppFlavorConfig.logoPath, width: 200, height: 200);
  }

  /// Build the app title
  Widget _buildAppTitle() {
    return Text(
      "APP_TITLE".tr,
      style: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  /// Build the status widget (loading or no internet message)
  Widget _buildStatusWidget() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (!_hasInternet) {
      return _buildNoInternetWidget();
    }

    return const SizedBox.shrink();
  }

  /// Build the no internet connection widget
  Widget _buildNoInternetWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Text(
            "NO_INTERNET_CONNECTION".tr,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _retryConnection,
            child: Text("TRY_AGAIN".tr),
          ),
        ],
      ),
    );
  }

  /// Retry connection when user clicks try again button
  void _retryConnection() {
    setState(() {
      _isLoading = true;
      _hasInternet = true;
    });
    _initializeApp();
  }
}
