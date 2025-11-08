import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legate_my_car/models/enums/lost_status.dart';
import 'package:legate_my_car/models/lost_car_model.dart';
import 'package:legate_my_car/utils/getOrCreatedd.dart';
import 'package:legate_my_car/widgets/google_sign_in_button.dart';
import '../viewmodels/missing_car_viewmodel.dart';
import '../theme/app_theme.dart';
import 'lost_car_form_view.dart';

class MyLostCarsView extends StatefulWidget {
  const MyLostCarsView({super.key});

  @override
  State<MyLostCarsView> createState() => _MyLostCarsViewState();
}

class _MyLostCarsViewState extends State<MyLostCarsView> {
  final viewModel = GetOrCreated.getOrPut<MissingCarViewModel>(
    () => MissingCarViewModel(),
  );
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Refresh guest check when view is opened (useful after login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.refreshGuestCheck();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (viewModel.hasMorePages.value && !viewModel.isLoading.value) {
        viewModel.currentPage.value++;
        viewModel.loadMissingCars();
      }
    }
  }

  void _navigateToAddNewCar() {
    // Navigate to add new car form (null car means create mode)
    Get.to(() => const LostCarFormView(car: null))?.then((result) {
      if (result == true) {
        // Refresh the list after adding
        viewModel.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading while checking if user is guest
      if (viewModel.isCheckingGuest.value) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(
              'MY_LOST_CARS'.tr,
              style: const TextStyle(
                color: AppTheme.sudanWhite,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.sudanWhite,
            elevation: 2,
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToAddNewCar(),
            backgroundColor: AppTheme.primaryColor,
            icon: const Icon(Icons.add, color: AppTheme.sudanWhite),
            label: Text(
              'ADD_NEW_CAR'.tr,
              style: const TextStyle(
                color: AppTheme.sudanWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        );
      }

      // If guest, show message (dialog is already shown, but show placeholder UI)
      if (viewModel.isGuest.value) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(
              'MY_LOST_CARS'.tr,
              style: const TextStyle(
                color: AppTheme.sudanWhite,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.sudanWhite,
            elevation: 2,
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(25),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 64,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LOGIN_REQUIRED'.tr,
                    style: const TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LOGIN_REQUIRED_MESSAGE'.tr,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: GoogleSignInButton(
                      showAsOutline: false,
                      padding: EdgeInsets.zero,
                      redirectToMyLostCars: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Normal view for non-guest users
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            'MY_LOST_CARS'.tr,
            style: const TextStyle(
              color: AppTheme.sudanWhite,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.sudanWhite,
          elevation: 2,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => viewModel.refresh(),
              tooltip: 'REFRESH_ICON'.tr,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToAddNewCar(),
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.add, color: AppTheme.sudanWhite),
          label: Text(
            'ADD_NEW_CAR'.tr,
            style: const TextStyle(
              color: AppTheme.sudanWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Obx(() {
          if (viewModel.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            );
          }

          if (viewModel.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.error.value,
                    style: const TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    child: Text('RETRY'.tr),
                  ),
                ],
              ),
            );
          }

          if (viewModel.missingCars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 64,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NO_LOST_CARS'.tr,
                    style: const TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'REPORT_MISSING_CAR_HINT'.tr,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount:
                viewModel.missingCars.length +
                (viewModel.hasMorePages.value ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end if there are more pages
              if (index == viewModel.missingCars.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                );
              }

              final car = viewModel.missingCars[index];
              return MyLostCarCard(car: car, viewModel: viewModel);
            },
          );
        }),
      );
    });
  }
}

class MyLostCarCard extends StatelessWidget {
  final LostCarModel car;
  final MissingCarViewModel viewModel;

  const MyLostCarCard({super.key, required this.car, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    (car.carName?.isNotEmpty ?? false)
                        ? car.carName!
                        : car.plateNumber ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
                if (car.status != null) ...[
                  const SizedBox(width: 12),
                  _StatusBadge(status: car.status!),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Car details
            _buildDetailRow('PLATE_NUMBER'.tr, car.plateNumber ?? ''),
            _buildDetailRow('COLOR'.tr, car.color ?? ''),
            _buildDetailRow(
              'LAST_KNOWN_LOCATION'.tr,
              car.lastKnownLocation ?? '',
            ),
            _buildDetailRow('PHONE_NUMBER'.tr, car.phoneNumber ?? ''),

            // Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.to(() => LostCarFormView(car: car));
                  if (result == true) {
                    await viewModel.refresh();
                  }
                },
                icon: const Icon(Icons.edit),
                label: Text('UPDATE_LOST_CAR'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.sudanWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final LostStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case LostStatus.lost:
        backgroundColor = AppTheme.errorColor.withValues(alpha: 0.14);
        textColor = AppTheme.errorColor;
        break;
      case LostStatus.found:
        backgroundColor = Colors.green.withValues(alpha: 0.12);
        textColor = Colors.green.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: textColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == LostStatus.found ? Icons.check_circle : Icons.error,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            status.translatedStatus,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
