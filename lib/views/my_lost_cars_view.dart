import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legate_my_car/utils/getOrCreatedd.dart';
import 'package:legate_my_car/widgets/google_sign_in_button.dart';
import '../viewmodels/missing_car_viewmodel.dart';
import '../models/missing_car_model.dart';
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
        viewModel.loadNextPage();
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
  final MissingCarModel car;
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
            // Header with status and edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    car.fullCarName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    car.status.tr,
                    style: const TextStyle(
                      color: AppTheme.sudanWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Car details
            _buildDetailRow('PLATE_NUMBER'.tr, car.plateNumber),
            _buildDetailRow('COLOR'.tr, car.color),
            _buildDetailRow('LAST_KNOWN_LOCATION'.tr, car.lastKnownLocation),
            _buildDetailRow('MISSING_DATE'.tr, car.formattedMissingDate),

            if (car.hasReward)
              _buildDetailRow('REWARD_AMOUNT'.tr, car.rewardAmount!),

            const SizedBox(height: 12),

            // Description
            if (car.description.isNotEmpty) ...[
              Text(
                'DESCRIPTION'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                car.description,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
            ],

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
