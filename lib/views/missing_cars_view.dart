import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/missing_car_viewmodel.dart';
import '../models/missing_car_model.dart';
import '../theme/app_theme.dart';

class MissingCarsView extends StatelessWidget {
  const MissingCarsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.put(MissingCarViewModel());

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'MISSING_CARS_TITLE'.tr,
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
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          );
        }

        if (viewModel.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
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

        final filteredCars = viewModel.filteredMissingCars;

        if (filteredCars.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'NO_CARS_FOUND'.tr,
                  style: const TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'TRY_ADJUSTING_SEARCH'.tr,
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

        return Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.surfaceColor,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (value) => viewModel.searchMissingCars(value),
                    decoration: InputDecoration(
                      hintText: 'SEARCH_HINT'.tr,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: viewModel.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => viewModel.clearSearch(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Status Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: viewModel.statusOptions.map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status.tr),
                            selected: viewModel.selectedStatus.value == status,
                            onSelected: (selected) {
                              if (selected) {
                                viewModel.filterByStatus(status);
                              }
                            },
                            selectedColor: AppTheme.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            checkmarkColor: AppTheme.primaryColor,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // Cars List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredCars.length,
                itemBuilder: (context, index) {
                  final car = filteredCars[index];
                  return MissingCarCard(car: car, viewModel: viewModel);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class MissingCarCard extends StatelessWidget {
  final MissingCarModel car;
  final MissingCarViewModel viewModel;

  const MissingCarCard({super.key, required this.car, required this.viewModel});

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
            // Header with status
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

            // Contact button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final contactInfo = viewModel.contactOwner(car);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contact: $contactInfo'),
                      behavior: SnackBarBehavior.fixed,
                    ),
                  );
                },
                icon: const Icon(Icons.contact_phone),
                label: Text('CONTACT_OWNER'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
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
