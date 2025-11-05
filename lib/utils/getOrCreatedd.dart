import 'package:get/get.dart';

/// Utility class for GetX controller management
class GetOrCreated {
  /// Get an existing controller if registered, or create and register a new one
  ///
  /// Usage:
  /// ```dart
  /// final viewModel = GetOrCreated.getOrPut(() => MyViewModel());
  /// ```
  ///
  /// Or with a controller that's already instantiated:
  /// ```dart
  /// final controller = GetOrCreated.getOrPut(() => MyController());
  /// ```
  static T getOrPut<T extends GetxController>(T Function() builder) {
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    } else {
      return Get.put(builder());
    }
  }

  /// Get an existing controller if registered, or create and register a new one with a tag
  ///
  /// Usage:
  /// ```dart
  /// final viewModel = GetOrCreated.getOrPutWithTag(
  ///   () => MyViewModel(),
  ///   tag: 'unique-tag',
  /// );
  /// ```
  static T getOrPutWithTag<T extends GetxController>(
    T Function() builder, {
    String? tag,
  }) {
    if (Get.isRegistered<T>(tag: tag)) {
      return Get.find<T>(tag: tag);
    } else {
      return Get.put(builder(), tag: tag);
    }
  }

  /// Get an existing controller if registered, or create and register a new one permanently
  /// Permanent controllers are not removed when route changes
  ///
  /// Usage:
  /// ```dart
  /// final controller = GetOrCreated.getOrPutPermanent(() => MyController());
  /// ```
  static T getOrPutPermanent<T extends GetxController>(T Function() builder) {
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    } else {
      return Get.put(builder(), permanent: true);
    }
  }

  /// Try to get a controller if registered, return null if not found
  ///
  /// Usage:
  /// ```dart
  /// final controller = GetOrCreated.tryGet<MyController>();
  /// if (controller != null) {
  ///   // Use controller
  /// }
  /// ```
  static T? tryGet<T extends GetxController>({String? tag}) {
    if (Get.isRegistered<T>(tag: tag)) {
      return Get.find<T>(tag: tag);
    }
    return null;
  }

  /// Check if a controller is registered
  ///
  /// Usage:
  /// ```dart
  /// if (GetOrCreated.isRegistered<MyController>()) {
  ///   // Controller exists
  /// }
  /// ```
  static bool isRegistered<T extends GetxController>({String? tag}) {
    return Get.isRegistered<T>(tag: tag);
  }
}
