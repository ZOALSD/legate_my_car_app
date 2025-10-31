enum AppEnvironment { staging, production }

class EnvConfig {
  // Environment configuration
  // Change this to switch between staging and production
  static const AppEnvironment environment = AppEnvironment.staging;

  // API URLs for different environments
  static const Map<AppEnvironment, String> _apiUrls = {
    AppEnvironment.staging: 'staging.laqeetarabeety.com',
    AppEnvironment.production: 'api.laqeetarabeety.com',
  };

  // Get the API host URL based on current environment
  static String get defaultApiUrl => _apiUrls[environment]!;

  // Full base URL with protocol
  static String get apiBaseUrl => 'https://$defaultApiUrl/api/v1';

  // API version and base path
  static const String apiVersion = 'v1';
  static String get apiPath => '/api/$apiVersion';

  // Helper to check current environment
  static bool get isStaging => environment == AppEnvironment.staging;
  static bool get isProduction => environment == AppEnvironment.production;

  static bool get showDebugBanner => isStaging;
}
