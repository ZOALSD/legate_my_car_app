class AppConstants {
  // API Endpoints
  static const String carsEndpoint = '/cars';
  static const String searchEndpoint = '/cars/search';

  // App Information
  static const String appName = 'Legate My Car';
  static const String appVersion = '1.0.0';

  // Car Status Options
  static const List<String> carStatuses = ['all', 'lost', 'found', 'recovered'];

  // Search Debounce Duration (in milliseconds)
  static const int searchDebounceMs = 500;

  // Pagination
  static const int defaultPageSize = 20;

  // Image Placeholder
  static const String imagePlaceholder = 'assets/images/car_placeholder.png';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred.';

  // Success Messages
  static const String dataLoadedMessage = 'Data loaded successfully';
  static const String searchClearedMessage = 'Search cleared';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
