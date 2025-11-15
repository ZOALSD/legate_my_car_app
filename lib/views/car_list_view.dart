import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:legate_my_car/theme/app_theme.dart';
import 'package:legate_my_car/views/car_form_view.dart';
import 'package:legate_my_car/views/car_single_view.dart';
import 'package:legate_my_car/views/search_Widget.dart';
import 'package:legate_my_car/views/menu_view.dart';
import '../viewmodels/car_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/car_model.dart';
import '../config/app_flavor.dart';
import 'dart:ui' as ui;
import 'package:visibility_detector/visibility_detector.dart';

class _AppConstants {
  static const double cardBorderRadius = 12.0;
  static const double gridSpacing = 12.0;
  static const double cardAspectRatio = 0.75;
  static const int gridCrossAxisCount = 2;
  static const double paginationTriggerDistance = 200.0;
  static const double headerPadding = 20.0;
}

class CarListView extends StatefulWidget {
  const CarListView({super.key});

  @override
  State<CarListView> createState() => _CarListViewState();
}

class _CarListViewState extends State<CarListView> {
  CarViewModel viewModel = CarViewModel.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.removeListener(_onSearchChanged);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent -
            _AppConstants.paginationTriggerDistance) {
      if (viewModel.hasMorePages && !viewModel.isLoading) {
        viewModel.loadNextPage();
      }
    }
  }

  void _onSearchChanged() {
    // setState(() {
    //   // This will trigger a rebuild to show/hide the clear button
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchWidget(
                searchController: _searchController,
                viewModel: viewModel,
              ),
            ),
            Expanded(
              child: Obx(
                () => viewModel.isLoading && viewModel.cars.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.cars.isEmpty
                    ? Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                          Visibility(
                            visible: viewModel.searchQuery.isNotEmpty,
                            replacement: const SizedBox.shrink(),
                            child: Text(
                              "NO_CARS_FOUND".tr,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await viewModel.refresh();
                        },
                        color: Colors.white,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cars Grid
                              _buildCarsGrid(),
                              // Pagination indicators
                              _buildPaginationIndicators(),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFlavorConfig.isManagers
          ? FloatingActionButton(
              backgroundColor: Color(0xFF009A49),
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CarFormView()),
                );
              },
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _AppConstants.headerPadding,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              SvgPicture.asset(AppFlavorConfig.logoPath, width: 40, height: 40),
              Text(
                "APP_TITLE".tr,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          MenuView(
            onCarAdded: (CarModel car) => viewModel.addCar(car),
            onCarUpdated: (CarModel car) => viewModel.updateCar(car),
          ),
        ],
      ),
    );
  }

  Widget _buildCarsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _AppConstants.gridCrossAxisCount,
        childAspectRatio: _AppConstants.cardAspectRatio,
        crossAxisSpacing: _AppConstants.gridSpacing,
        mainAxisSpacing: _AppConstants.gridSpacing,
      ),
      itemCount: viewModel.cars.length,
      itemBuilder: (context, index) {
        final vehicle = viewModel.cars[index];
        return _buildCarCard(vehicle, index);
      },
    );
  }

  Widget _buildPaginationIndicators() {
    return Column(
      children: [
        // Pagination loading indicator
        if (viewModel.isLoading && viewModel.cars.isNotEmpty)
          Container(
            padding: EdgeInsets.all(20),
            child: const Center(child: CircularProgressIndicator()),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCarCard(CarModel vehicle, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarSingleView(
              car: vehicle,
              isManagerRoll: viewModel.isManagerRoll,
            ),
          ),
        ).then((result) {
          // Handle result from CarSingleView (when car is edited there)
          if (result != null && result is Map) {
            final car = result['car'] as CarModel?;
            final action = result['action'] as String?;

            if (car != null && action != null) {
              if (action == 'update') {
                viewModel.updateCar(car);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarSingleView(
                      car: car,
                      isManagerRoll: viewModel.isManagerRoll,
                    ),
                  ),
                );
              } else if (action == 'create') {
                viewModel.addCar(car);
              }
            }
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_AppConstants.cardBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image with lazy loading
            Expanded(flex: 4, child: _buildLazyImage(vehicle, index)),

            // Car Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Text(
                        "${vehicle.number?.toString() ?? " "} - ${vehicle.chassisNumber ?? " - "}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      vehicle.plateNumber ?? " - ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${vehicle.modelYear?.toString() ?? " "} - ${vehicle.carName ?? ""}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLazyImage(CarModel vehicle, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      child: vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty
          ? _LazyCachedImage(imageUrl: vehicle.imageUrl!, index: index)
          : Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[800],
              child: Icon(
                Icons.car_crash_outlined,
                color: Colors.grey[400],
                size: 80,
              ),
            ),
    );
  }
}

class _LazyCachedImage extends StatefulWidget {
  final String imageUrl;
  final int index;

  const _LazyCachedImage({required this.imageUrl, required this.index});

  @override
  State<_LazyCachedImage> createState() => _LazyCachedImageState();
}

class _LazyCachedImageState extends State<_LazyCachedImage> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('visibility_${widget.imageUrl}_${widget.index}'),
      onVisibilityChanged: (VisibilityInfo info) {
        // Load image when it becomes visible (threshold: 50% visible)
        if (info.visibleFraction > 0.5 && !_isVisible) {
          if (mounted) {
            setState(() {
              _isVisible = true;
            });
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[800],
        child: _isVisible
            ? CachedNetworkImage(
                imageUrl: widget.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                // Optimize memory usage
                memCacheWidth: 500,
                memCacheHeight: 500,
                // Optimize disk cache
                maxWidthDiskCache: 1000,
                maxHeightDiskCache: 1000,
                // Smooth fade-in animation
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 100),
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: Icon(
                    Icons.car_rental,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                ),
              )
            : Container(
                color: Colors.grey[800],
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ),
      ),
    );
  }
}
