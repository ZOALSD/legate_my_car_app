import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import '../theme/app_theme.dart';

class LocationPickerView extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerView({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  final MapController _mapController = MapController();
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'User-Agent': 'LegateMyCar/1.0',
        'Accept': 'application/json',
        'Connection': 'keep-alive',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      followRedirects: true,
      maxRedirects: 3,
    ),
  );
  final CancelToken _cancelToken = CancelToken();
  LatLng _selectedLocation = const LatLng(15.4542, 32.5322);
  String _address = '';
  bool _hasNetworkError = false;
  bool _isLoading = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
    }
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _cancelToken.cancel();
    _dio.close();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  Future<void> _retryWithBackoff() async {
    if (_retryCount >= _maxRetries) {
      _retryCount = 0;
      return;
    }

    _retryCount++;
    final delay = Duration(seconds: _retryCount * 2);
    await Future.delayed(delay);

    if (mounted) {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permission denied'.tr),
              action: SnackBarAction(
                label: 'Settings'.tr,
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permission permanently denied'.tr),
              action: SnackBarAction(
                label: 'Settings'.tr,
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location services are disabled'.tr),
              action: SnackBarAction(
                label: 'Settings'.tr,
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_selectedLocation, 15);
      await _updateAddress(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        setState(() {
          _address =
              'Location: ${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get current location'.tr)),
        );
      }
    }
  }

  void _debouncedUpdateAddress(double lat, double lon) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _updateAddress(lat, lon);
    });
  }

  Future<void> _updateAddress(double lat, double lon) async {
    final coordinateString =
        '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';
    if (!mounted) return;
    setState(() {
      _address = 'Location: $coordinateString';
      _isLoading = true;
    });

    if (!await _checkConnectivity()) {
      if (mounted) {
        setState(() {
          _hasNetworkError = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No internet connection'.tr)));
      }
      return;
    }

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lon,
          'zoom': 18,
          'addressdetails': 1,
        },
        cancelToken: _cancelToken,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['display_name'] != null) {
        if (mounted) {
          setState(() {
            _address = response.data['display_name'];
            _hasNetworkError = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address = 'Location: $coordinateString';
          _hasNetworkError = true;
          _isLoading = false;
        });

        // Show retry option for network errors
        if (e is DioException &&
            (e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.connectionError)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Network error. Retrying...'.tr),
              action: SnackBarAction(
                label: 'Retry'.tr,
                onPressed: () => _updateAddress(lat, lon),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to fetch address'.tr)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pick Location'.tr,
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
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _hasNetworkError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.wifi_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Internet Connection'.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                'Please check your internet connection to load the map'
                                    .tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                if (await _checkConnectivity()) {
                                  setState(() {
                                    _hasNetworkError = false;
                                    _retryCount = 0;
                                  });
                                  await _getCurrentLocation();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Still no connection'.tr),
                                      action: SnackBarAction(
                                        label: 'Retry'.tr,
                                        onPressed: () async {
                                          await _retryWithBackoff();
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text('Retry'.tr),
                            ),
                          ],
                        ),
                      )
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: _selectedLocation,
                          zoom: 15,
                          minZoom: 5,
                          maxZoom: 18,
                          onTap: (tapPosition, point) {
                            setState(() {
                              _selectedLocation = point;
                            });
                            _debouncedUpdateAddress(
                              point.latitude,
                              point.longitude,
                            );
                          },
                          onMapReady: () {
                            // Handle map ready
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.laqeetarabeety.managers',
                            maxZoom: 18,
                            errorTileCallback: (tile, error, __) {
                              if (!mounted) return;

                              // Only show error for critical failures, not individual tile failures
                              if (error.toString().contains('network')) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    setState(() {
                                      _hasNetworkError = true;
                                    });
                                  }
                                });
                              }
                            },
                            tileBuilder: (context, tileWidget, tile) {
                              return tileWidget;
                            },
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation,
                                width: 50,
                                height: 50,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 50,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                Positioned(
                  right: 16,
                  top: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "zoom_in_fab",
                        mini: true,
                        onPressed: () {
                          _mapController.move(
                            _mapController.center,
                            _mapController.zoom + 1,
                          );
                        },
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "zoom_out_fab",
                        mini: true,
                        onPressed: () {
                          _mapController.move(
                            _mapController.center,
                            _mapController.zoom - 1,
                          );
                        },
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  _address.isNotEmpty ? _address : 'Tap to select location'.tr,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(
                        result: {
                          'latitude': _selectedLocation.latitude,
                          'longitude': _selectedLocation.longitude,
                          'address': _address,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(
                      'Confirm Location'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
