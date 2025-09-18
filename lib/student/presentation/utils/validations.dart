class Validations {
  static String? validateName(String? value) {
    if (value == null || value.trim().length <= 3) {
      return 'Name must be more than 3 characters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null) {
      return 'Phone number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (digitsOnly.length >= 15) {
      return 'Phone number must be less than 15 digits';
    }
    return null;
  }
}
