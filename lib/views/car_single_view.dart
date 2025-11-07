import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:legate_my_car/config/app_flavor.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/car_model.dart';
import 'car_form_view.dart';
import '../theme/app_theme.dart';

class CarSingleView extends StatelessWidget {
  final CarModel car;

  const CarSingleView({super.key, required this.car});

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
                const SizedBox(height: 100), // Bottom padding for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
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
          _buildDetailRow('CHASSIS_NUMBER'.tr, car.chassisNumber ?? " - "),
          _buildDetailRow('PLATE_NUMBER'.tr, car.plateNumber ?? " - "),
          Visibility(
            visible: AppFlavorConfig.isManagers,
            child: _buildDetailRow('LOCATION'.tr, car.location ?? " - "),
          ),
          _buildDetailRow('BRAND'.tr, car.modelYear ?? " - "),
          _buildDetailRow('MODEL'.tr, car.model ?? " - "),
          _buildDetailRow('DESCRIPTION'.tr, car.description ?? " - "),
        ],
      ),
    );
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

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => {
        if (AppFlavorConfig.isManagers)
          {_shareLocation(context)}
        else
          {_contactUs(context)},
      },
      icon: AppFlavorConfig.isManagers
          ? const Icon(Icons.location_on, color: Colors.white)
          : SvgPicture.asset(
              'assets/images/whatsapp.svg',
              width: 30,
              height: 30,
            ),
      label: Text(
        AppFlavorConfig.isManagers ? "SHARE_LOCATION".tr : "CONTACT_US".tr,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _shareCar(BuildContext context) {
    // TODO: Implement share functionality
  }

  Future<void> _contactUs(BuildContext context) async {
    const phoneNumber = '+971507632287'; //'+249900999000';
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
    // use latitude and longitude to share location
    final latitude = car.latitude;
    final longitude = car.longitude;
    if (latitude != null && longitude != null) {
      // Create Google Maps URL
      final googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

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
