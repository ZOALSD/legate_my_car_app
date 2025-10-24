class EnvConfig {
  // Default API URL - replace with your actual API URL
  static const String defaultApiUrl = 'https://api.example.com';

  // Get API URL from environment or use default
  static String get apiBaseUrl {
    // In a real app, you would load this from environment variables
    // For now, we'll use a default URL
    return defaultApiUrl;
  }
}
