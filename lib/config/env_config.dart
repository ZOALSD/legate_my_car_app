class EnvConfig {
  // Default API URL - replace with your actual API URL
  // Note: If the API server is not accessible, the app will automatically
  // fall back to using demo data for demonstration purposes.
  static const String defaultApiUrl = 'api.laqeetarabeety.com';
  static const String apiVersion = 'v1';
  static String get apiBaseUrl => '/api/$apiVersion';
}
