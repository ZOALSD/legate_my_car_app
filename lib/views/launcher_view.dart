import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../config/app_flavor.dart';
import 'car_list_view.dart';
import 'login_view.dart';
import '../services/auth_service.dart';
import '../utils/connection_helper.dart';

class LauncherView extends StatefulWidget {
  final VoidCallback? onComplete;

  const LauncherView({super.key, this.onComplete});

  @override
  State<LauncherView> createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> {
  final PageController _pageController = PageController();
  late final List<FeatureItem> _features;
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Enable full screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _features = [
      FeatureItem(
        child: _buildAppTitleVisual(),
        title: 'APP_TITLE',
        description: 'APP_SUBTITLE',
      ),
      FeatureItem(
        child: _buildSearchFeatureVisual(),
        title: 'SEARCH_LOST_CAR',
        description: 'SEARCH_LOST_CAR_DESCRIPTION',
      ),
      FeatureItem(
        child: _buildAddRequestFeatureVisual(),
        title: 'ADD_REQUEST',
        description: 'ADD_REQUEST_DESCRIPTION',
      ),
    ];
  }

  @override
  void dispose() {
    // Restore system UI when leaving the launcher
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _getStarted() async {
    if (_isLoading) return;

    // Call onComplete callback if provided (to mark launcher as seen)
    widget.onComplete?.call();

    setState(() {
      _isLoading = true;
    });

    try {
      // Check internet connectivity
      final hasInternet = await ConnectionHelper.hasInternet();

      if (!hasInternet) {
        if (mounted) {
          Get.snackbar(
            'ERROR'.tr,
            'NO_INTERNET_CONNECTION'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.errorColor,
            colorText: Colors.white,
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Check if user is already authenticated
      final isAuthenticated = await AuthService.isAuthenticated();

      if (isAuthenticated) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CarListView()),
          );
        }
        return;
      }

      // Handle unauthenticated users based on flavor
      if (AppFlavorConfig.isManagers) {
        // Managers flavor: show login screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
          );
        }
      } else {
        // Clients flavor: attempt guest login
        final loginSuccess = await AuthService.loginAsGuest();
        if (loginSuccess && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CarListView()),
          );
        } else if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
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
    // Get status bar height for manual padding
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Top padding for status bar area
          SizedBox(height: statusBarHeight),
          // Skip button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton(
                onPressed: _getStarted,
                child: Text(
                  'SKIP'.tr,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Visual spacer
          const SizedBox(height: 40),

          // Features PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _features.length,
              itemBuilder: (context, index) {
                return _buildFeaturePage(_features[index]);
              },
            ),
          ),

          // Page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _features.length,
              (index) => _buildPageIndicator(index == _currentPage),
            ),
          ),
          const SizedBox(height: 30),

          // Get Started button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _getStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.sudanWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.sudanWhite,
                          ),
                        ),
                      )
                    : Text(
                        'GET_STARTED'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(height: 30 + bottomPadding),
        ],
      ),
    );
  }

  Widget _buildFeaturePage(FeatureItem feature) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFiniteHeight = constraints.maxHeight.isFinite;

        Widget content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Feature visual
            Container(
              constraints: const BoxConstraints(maxWidth: 260, minHeight: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                    AppTheme.primaryColor.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: feature.child,
            ),
            const SizedBox(height: 32),

            // Feature title
            Text(
              feature.title.tr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Feature description
            Text(
              feature.description.tr,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
        );

        if (hasFiniteHeight) {
          content = ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(alignment: Alignment.center, child: content),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          physics: const BouncingScrollPhysics(),
          child: content,
        );
      },
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSearchFeatureVisual() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Icon(
            Icons.directions_car,
            size: 120,
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchFieldSkeleton(width: 200),
            const SizedBox(height: 12),
            _buildSearchResultRow(isHighlighted: true),
            const SizedBox(height: 10),
            _buildSearchResultRow(),
            const SizedBox(height: 10),
            _buildSearchResultRow(),
          ],
        ),
        Positioned(
          top: -10,
          left: -10,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildAddRequestFeatureVisual() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          child: Icon(
            Icons.directions_car,
            size: 150,
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormFieldSkeleton(width: 200),
              const SizedBox(height: 10),
              _buildFormFieldSkeleton(width: 180),
              const SizedBox(height: 10),
              _buildFormFieldSkeleton(width: 160),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildFormFieldSkeleton(height: 32)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildFormFieldSkeleton(height: 32)),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'ADD_REQUEST'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchFieldSkeleton({double width = 200}) {
    return Container(
      width: width,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultRow({bool isHighlighted = false}) {
    return Container(
      width: double.infinity,
      height: 38,
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.primaryColor.withValues(alpha: 0.15)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.directions_car_filled,
            color: AppTheme.primaryColor.withValues(alpha: 0.7),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldSkeleton({
    double width = double.infinity,
    double height = 36,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: width == double.infinity ? 80 : width * 0.5,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildAppTitleVisual() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.15),
                AppTheme.primaryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: SvgPicture.asset(
            AppFlavorConfig.logoPath,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class FeatureItem {
  final Widget child;
  final String title;
  final String description;

  FeatureItem({
    required this.child,
    required this.title,
    required this.description,
  });
}
