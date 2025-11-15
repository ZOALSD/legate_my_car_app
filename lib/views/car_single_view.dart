import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:legate_my_car/config/app_flavor.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/car_model.dart';
import '../services/auth_service.dart';
import 'car_form_view.dart';
import '../theme/app_theme.dart';

class CarSingleView extends StatelessWidget {
  final CarModel car;
  final bool isManagerRoll;

  const CarSingleView({
    super.key,
    required this.car,
    required this.isManagerRoll,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCarImage(),
                _buildCarDetails(),
                _buildUserInfoSection(),
                const SizedBox(height: 100), // Bottom padding for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.grey.shade200,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Visibility(
          visible: AppFlavorConfig.isManagers,
          child: IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
            onPressed: () => _editCar(context),
            tooltip: 'EDIT_CAR'.tr,
          ),
        ),
        // IconButton(
        //   icon: const Icon(Icons.share, color: Colors.black),
        //   onPressed: () => _shareCar(context),
        //   tooltip: 'SHARE_CAR'.tr,
        // ),
      ],
    );
  }

  Widget _buildCarImage() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          car.imageUrl != null && car.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: car.imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.white,
                    child: const Center(
                      child: Icon(
                        Icons.car_rental,
                        color: Colors.grey,
                        size: 80,
                      ),
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: const Center(
                    child: Icon(Icons.car_rental, color: Colors.grey, size: 80),
                  ),
                ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          // Status badge
        ],
      ),
    );
  }

  Widget _buildCarDetails() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('CAR_NAME'.tr, car.carName ?? " - "),
          _buildDetailRow('CHASSIS_NUMBER'.tr, car.chassisNumber ?? " - "),
          _buildDetailRow('PLATE_NUMBER'.tr, car.plateNumber ?? " - "),
          Visibility(
            visible: AppFlavorConfig.isManagers,
            child: _buildLocationRow(),
          ),
          _buildDetailRow('MODEL_YEAR'.tr, car.modelYear?.toString() ?? " - "),
          _buildDetailRow('DESCRIPTION'.tr, car.description ?? " - "),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return FutureBuilder(
      future: AuthService.getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        if (!isManagerRoll || car.user == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UPLOAD_BY'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('NAME'.tr, car.user?.name ?? ' - '),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "EMAIL".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    car.user?.email ?? ' - ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationRow() {
    final locationText = car.location ?? " - ";

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  'LOCATION'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 7,
                child: Text(
                  locationText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Divider(color: Colors.grey.withValues(alpha: 0.5), thickness: .5),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }

  String? _getGoogleMapsUrl() {
    final latitude = car.latitude;
    final longitude = car.longitude;
    if (latitude != null && longitude != null) {
      return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    }
    return null;
  }

  Future<void> _copyLocation(BuildContext context) async {
    final googleMapsUrl = _getGoogleMapsUrl();
    if (googleMapsUrl != null) {
      await Clipboard.setData(ClipboardData(text: googleMapsUrl));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('LOCATION_COPIED'.tr),
            backgroundColor: AppTheme.secondaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('LOCATION_NOT_AVAILABLE'.tr),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 7,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: label != 'DESCRIPTION'.tr,
          child: Column(
            children: [
              Divider(color: Colors.grey.withValues(alpha: 0.5), thickness: .5),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    if (!isManagerRoll && AppFlavorConfig.isManagers) {
      return const SizedBox.shrink();
    }

    if (AppFlavorConfig.isManagers) {
      // Show both share and copy buttons for managers
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            label: Text('COPY_LOCATION'.tr),
            heroTag: "copy_location",
            onPressed: () => _copyLocation(context),
            backgroundColor: AppTheme.primaryColor,
            icon: const Icon(Icons.copy, color: Colors.white),
            tooltip: 'COPY_LOCATION'.tr,
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: "share_location",
            onPressed: () => _shareLocation(context),
            backgroundColor: AppTheme.primaryColor,
            icon: const Icon(Icons.location_on, color: Colors.white),
            label: Text(
              "SHARE_LOCATION".tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else {
      // Show contact button for clients
      return FloatingActionButton.extended(
        heroTag: "contact_us",
        onPressed: () => _contactUs(context),
        backgroundColor: AppTheme.primaryColor,
        icon: SvgPicture.asset(
          'assets/images/whatsapp.svg',
          width: 30,
          height: 30,
        ),
        label: Text(
          "CONTACT_US".tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Future<void> _contactUs(BuildContext context) async {
    const phoneNumber = '+249900999000'; //'+249900999000';
    final chassisNumber = car.chassisNumber ?? '';

    // Create message with chassis number and request text
    final message = '${'CHASSIS_NUMBER'.tr}: $chassisNumber';
    final encodedMessage = Uri.encodeComponent(message);

    // Use platform-specific WhatsApp URL schemes
    String whatsappUrl;
    if (Platform.isIOS) {
      // iOS WhatsApp URL scheme: whatsapp://send?phone=PHONE&text=MESSAGE
      whatsappUrl = 'whatsapp://send?phone=$phoneNumber&text=$encodedMessage';
    } else if (Platform.isAndroid) {
      // Android WhatsApp URL scheme: https://wa.me/PHONE?text=MESSAGE
      // Remove + from phone number for wa.me
      final cleanPhone = phoneNumber.replaceAll('+', '');
      whatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';
    } else {
      // Fallback to web version
      final cleanPhone = phoneNumber.replaceAll('+', '');
      whatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';
    }

    try {
      final uri = Uri.parse(whatsappUrl);
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      // If direct scheme fails, try web version as fallback
      if (!launched && (Platform.isIOS || Platform.isAndroid)) {
        final cleanPhone = phoneNumber.replaceAll('+', '');
        final webWhatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';
        final webUri = Uri.parse(webWhatsappUrl);
        launched = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('UNABLE_TO_OPEN_WHATSAPP'.tr),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      // Handle platform exception or other errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('UNABLE_TO_OPEN_WHATSAPP'.tr),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _editCar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarFormView(car: car)),
    ).then((result) {
      // Pass the result back to list view if car was updated/created
      if (result != null && context.mounted) {
        Navigator.pop(context, result);
      }
    });
  }

  Future<void> _shareLocation(BuildContext context) async {
    final googleMapsUrl = _getGoogleMapsUrl();
    if (googleMapsUrl != null) {
      // Create WhatsApp share URL with the location link
      final message = Uri.encodeComponent('Location: $googleMapsUrl');

      // Use platform-specific WhatsApp URL schemes
      String whatsappUrl;
      if (Platform.isIOS) {
        // iOS WhatsApp URL scheme
        whatsappUrl = 'whatsapp://send?text=$message';
      } else if (Platform.isAndroid) {
        // Android WhatsApp URL scheme
        whatsappUrl = 'https://wa.me/?text=$message';
      } else {
        // Fallback to web version
        whatsappUrl = 'https://wa.me/?text=$message';
      }

      try {
        final uri = Uri.parse(whatsappUrl);
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched && context.mounted) {
          // If direct scheme fails, try web version as fallback
          if (Platform.isIOS || Platform.isAndroid) {
            final webWhatsappUrl = 'https://wa.me/?text=$message';
            final webUri = Uri.parse(webWhatsappUrl);
            final webLaunched = await launchUrl(
              webUri,
              mode: LaunchMode.externalApplication,
            );
            if (!webLaunched && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('UNABLE_TO_OPEN_WHATSAPP'.tr)),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('UNABLE_TO_OPEN_WHATSAPP'.tr)),
            );
          }
        }
      } catch (e) {
        // Handle platform exception or other errors
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('UNABLE_TO_OPEN_WHATSAPP'.tr)));
        }
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('LOCATION_NOT_AVAILABLE'.tr)));
    }
  }
}
