import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberUtil {
  /// Format phone number to E.164 format for Firebase
  static String formatToE164(String phoneNumber, String countryCode) {
    // Remove any non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // If it doesn't start with +, add the country code
    if (!cleaned.startsWith('+')) {
      // Ensure country code starts with +
      String formattedCountryCode =
          countryCode.startsWith('+') ? countryCode : '+$countryCode';
      cleaned = '$formattedCountryCode$cleaned';
    }

    return cleaned;
  }

  /// Validate if phone number is in correct format
  static bool isValidPhoneNumber(String phoneNumber, String countryCode) {
    try {
      String e164Number = formatToE164(phoneNumber, countryCode);
      return e164Number.length >= 10 && e164Number.length <= 15;
    } catch (e) {
      return false;
    }
  }

  /// Get country code from phone number input
  static String getCountryCode(PhoneNumber phoneNumber) {
    return phoneNumber.phoneNumber ?? '';
  }

  /// Convert PhoneNumber to E.164 string
  static String phoneNumberToE164(PhoneNumber phoneNumber) {
    return phoneNumber.phoneNumber ?? '';
  }
}
