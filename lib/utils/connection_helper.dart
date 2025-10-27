import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionHelper {
  static final _connectivity = Connectivity();

  /// Check if device has network connection
  static Future<bool> hasInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result.where((e) => e != ConnectivityResult.none).isNotEmpty;
  }

  /// Get current connection status stream
  static Stream<List<ConnectivityResult>> get connectionStream =>
      _connectivity.onConnectivityChanged;
}
