class AppWriteConfig {
  // AppWrite Project Configuration
  static const String PROJECT_ID = "688258d00034a1e36a9e";

  // Available AppWrite Endpoints
  static const String FRANKFURT_ENDPOINT =
      "https://frankfurt.cloud.appwrite.io/v1";
  static const String US_ENDPOINT = "https://cloud.appwrite.io/v1";
  static const String ASIA_ENDPOINT = "https://asia.cloud.appwrite.io/v1";

  // Current endpoint (change this if needed)
  static const String CURRENT_ENDPOINT = US_ENDPOINT;

  // Debug settings
  static const bool ENABLE_DEBUG_LOGS = true;

  // Network timeout settings (in seconds)
  static const int REQUEST_TIMEOUT = 30;
  static const int CONNECTION_TIMEOUT = 10;

  // Troubleshooting tips
  static const List<String> TROUBLESHOOTING_TIPS = [
    "1. Check your internet connection",
    "2. Verify the AppWrite project ID is correct",
    "3. Ensure the endpoint URL is correct",
    "4. Check if AppWrite service is available in your region",
    "5. Try using a different endpoint (US or Asia)",
    "6. Check your firewall/network settings",
    "7. Verify your AppWrite project settings",
  ];
}
