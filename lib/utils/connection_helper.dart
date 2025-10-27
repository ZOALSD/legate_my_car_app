import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionHelper {
  static final _internetChecker = InternetConnectionChecker();

  /// Check if device has internet connection
  static Future<bool> hasInternet() async {
    return await _internetChecker.hasConnection;
  }

  /// Get current connection status
  static Stream<InternetConnectionStatus> get connectionStream =>
      _internetChecker.onStatusChange;
}
