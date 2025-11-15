import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legate_my_car/config/app_flavor.dart';
import 'package:legate_my_car/models/car_model.dart';
import 'package:legate_my_car/models/enums/account_type.dart';
import 'package:legate_my_car/services/auth_service.dart';
import 'package:legate_my_car/views/car_list_view.dart';
import 'package:legate_my_car/views/login_view.dart';
import 'package:legate_my_car/views/user_list_view.dart';

import 'about_app_view.dart';
import 'car_form_view.dart';
import 'my_account_view.dart';
import 'my_lost_cars_view.dart';

class MenuView extends StatelessWidget {
  final Function(CarModel) onCarAdded;
  final Function(CarModel) onCarUpdated;

  const MenuView({
    super.key,
    required this.onCarAdded,
    required this.onCarUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 20,
      onPressed: () => _showMenu(context),
    );
  }

  Future<void> _showMenu(BuildContext context) async {
    // Wait for the next frame to ensure layout is complete
    await WidgetsBinding.instance.endOfFrame;

    if (!context.mounted) return;

    // Check if user is logged in and not a guest
    final user = await AuthService.getCurrentUser();
    final isLoggedIn = user != null && !user.isGuest;
    final isManagerRoll = user?.accountType == AccountType.manager;

    // Check context again after async operation
    if (!context.mounted) return;

    final overlayContext = Overlay.of(context);
    final RenderBox? overlay =
        overlayContext.context.findRenderObject() as RenderBox?;
    final RenderBox? buttonBox = context.findRenderObject() as RenderBox?;

    if (overlay == null || buttonBox == null || !buttonBox.hasSize) return;

    final Offset position = buttonBox.localToGlobal(Offset.zero);

    final String? selectedValue = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + buttonBox.size.height,
        overlay.size.width - position.dx - buttonBox.size.width,
        overlay.size.height - position.dy - buttonBox.size.height,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: [
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
        if (AppFlavorConfig.isClients)
          PopupMenuItem<String>(
            value: 'my_lost_cars',
            child: Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.grey),
                const SizedBox(width: 10),
                Text('MY_LOST_CARS'.tr),
              ],
            ),
          ),
        if (AppFlavorConfig.isManagers)
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
        if (AppFlavorConfig.isManagers && isManagerRoll)
          PopupMenuItem<String>(
            value: 'manage_users',
            child: Row(
              children: [
                const Icon(Icons.group, color: Colors.grey),
                const SizedBox(width: 10),
                Text('MANAGE_USERS'.tr),
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
        // Show logout only if user is logged in (not guest)
        if (isLoggedIn)
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                const Icon(Icons.logout, color: Colors.grey),
                const SizedBox(width: 10),
                Text('LOGOUT'.tr),
              ],
            ),
          ),
      ],
    );

    if (selectedValue != null && context.mounted) {
      _handleMenuSelection(context, selectedValue);
    }
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'my_account':
        Get.to(() => const MyAccountView());
        break;
      case 'my_lost_cars':
        Get.to(() => const MyLostCarsView());
        break;
      case 'upload_car':
        Get.to(() => CarFormView())?.then((result) {
          if (result != null && result is Map) {
            final car = result['car'] as CarModel?;
            final action = result['action'] as String?;

            if (car != null && action != null) {
              if (action == 'create') {
                onCarAdded(car);
              } else if (action == 'update') {
                onCarUpdated(car);
              }
            }
          }
        });
        break;
      case 'manage_users':
        Get.to(() => const UserListView());
        break;
      case 'about_app':
        Get.to(() => const AboutAppView());
        break;
      case 'logout':
        _handleLogout(context);
        break;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmLogout = await Get.dialog<bool>(
      AlertDialog(
        title: Text('LOGOUT'.tr),
        content: Text('LOGOUT_CONFIRM'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('CANCEL'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('LOGOUT'.tr),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      // Perform logout
      await AuthService.logout();
      if ((context.mounted)) {
        if (AppFlavorConfig.isClients) {
          // Redirect list view
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => CarListView()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
            (route) => false,
          );
        }
      }
    }
  }
}
