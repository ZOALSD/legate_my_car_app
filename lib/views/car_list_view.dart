import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:legate_my_car/views/add_car_view.dart';
import 'package:legate_my_car/views/car_single_view.dart';
import 'package:legate_my_car/views/search_Widget.dart';
import '../viewmodels/car_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/car_model.dart';

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
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Color(0xFF009A49),
      //   child: Icon(Icons.add, color: Colors.white),
      //   onPressed: () {
      //     // Navigate to add car screen
      //   },
      // ),
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
              SvgPicture.asset('assets/images/logo.svg', width: 40, height: 40),
              Text(
                "APP_TITLE".tr,
                style: TextStyle(
                  // color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              // Handle menu item selection
              switch (value) {
                case 'my_account':
                  // Navigate to my account page
                  break;
                case 'my_request':
                  // Navigate to my request page
                  break;
                case 'upload_car':
                  Get.to(
                    () => AddCarView(),
                  )?.then((_) => viewModel.loadCars(page: 1));
                  break;
                case 'about_app':
                  // Show about app dialog
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'my_account',
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text('MY_ACCOUNT'.tr),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'my_request',
                child: Row(
                  children: [
                    const Icon(Icons.request_page, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text('MY_REQUEST'.tr),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'upload_car',
                child: Row(
                  children: [
                    const Icon(Icons.add_circle, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text('UPLOAD_CAR'.tr),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'about_app',
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text('ABOUT_APP'.tr),
                  ],
                ),
              ),
            ],
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
          MaterialPageRoute(builder: (context) => CarSingleView(car: vehicle)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_AppConstants.cardBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child:
                        vehicle.fullImageUrl != null &&
                            vehicle.fullImageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: vehicle.fullImageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(),
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
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.car_crash_outlined,
                              color: Colors.grey[400],
                              size: 80,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // Car Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.chassisNumber ?? " - ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                      "${vehicle.brand ?? " "} - ${vehicle.model ?? ""}",
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
}
