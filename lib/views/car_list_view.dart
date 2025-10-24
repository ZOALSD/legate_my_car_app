import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:legate_my_car/views/car_single_view.dart';
import 'package:legate_my_car/views/search_Widget.dart';
import '../viewmodels/car_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/car_model.dart';

class _AppConstants {
  static const double cardBorderRadius = 12.0;
  static const double gridSpacing = 12.0;
  static const double cardAspectRatio = 0.8;
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
      // Load next page when user is near bottom
      if (viewModel.hasMorePages && !viewModel.isLoading) {
        viewModel.loadNextPage();
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      // This will trigger a rebuild to show/hide the clear button
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: Obx(
                () => viewModel.isLoading && viewModel.cars.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : viewModel.cars.isEmpty
                    ? Center(
                        child: Text(
                          'No cars found',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await viewModel.refresh();
                        },
                        color: Colors.white,
                        backgroundColor: Colors.grey[800],
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search Widget
                              SearchWidget(
                                searchController: _searchController,
                                viewModel: viewModel,
                              ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF009A49),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Navigate to add car screen
        },
      ),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(Icons.more_vert, color: Colors.white),
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
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // End of list indicator
        if (!viewModel.hasMorePages && viewModel.cars.isNotEmpty)
          Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No more cars to load',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
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
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(_AppConstants.cardBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: vehicle.imagePath ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
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
                    ),
                  ),
                  // New badge
                  if (index == 1 || index == 3)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'New',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
                    // Flag and Brand
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vehicle.brand,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      vehicle.model,
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Make a model',
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                    ),
                    Spacer(),
                    Text(
                      '2021',
                      style: TextStyle(color: Colors.grey[400], fontSize: 10),
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
