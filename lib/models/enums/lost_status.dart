import 'package:get/get_utils/get_utils.dart';

enum LostStatus { lost, found }

extension Translate on LostStatus {
  String get translatedStatus {
    switch (this) {
      case LostStatus.lost:
        return 'STATUS_LOST'.tr;
      case LostStatus.found:
        return 'STATUS_FOUND'.tr;
    }
  }
}
