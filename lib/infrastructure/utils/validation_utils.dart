class ValidationUtils {
  static const String _emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.gh$';

  static final RegExp _emailRegExp = RegExp(_emailRegex);

  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static String? validateEmail(String? email) {
    if (!isNotEmpty(email)) {
      return 'This field is required';
    }
    if (!isValidEmail(email!)) {
      return 'Email must end with .gh';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (!isNotEmpty(password)) {
      return 'This field is required';
    }
    if (!isValidPassword(password!)) {
      return 'Password is required';
    }
    return null;
  }

  static String? validateRequired(String? value) {
    if (!isNotEmpty(value)) {
      return 'This field is required';
    }
    return null;
  }
}
