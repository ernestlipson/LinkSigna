import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

mixin FirebaseExceptionMixin {
  /// Handles Firebase Auth exceptions and displays appropriate error messages
  void handleFirebaseAuthException(FirebaseAuthException e,
      {String? defaultMessage}) {
    String errorMessage = defaultMessage ?? 'An error occurred';

    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No account found with this email address';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password. Please try again';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address format';
        break;
      case 'user-disabled':
        errorMessage = 'This account has been disabled';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many requests. Please try again later';
        break;
      case 'operation-not-allowed':
        errorMessage = 'This operation is not allowed';
        break;
      case 'weak-password':
        errorMessage =
            'Password is too weak. Please choose a stronger password';
        break;
      case 'email-already-in-use':
        errorMessage = 'An account already exists with this email address';
        break;
      case 'invalid-credential':
        errorMessage =
            'Invalid credentials. Please check your email and password';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Please check your connection';
        break;
      case 'requires-recent-login':
        errorMessage = 'Please log in again to complete this action';
        break;
      default:
        errorMessage =
            e.message ?? defaultMessage ?? 'An unexpected error occurred';
    }

    _showError('Error', errorMessage);
  }

  /// Handles general Firebase exceptions
  void handleFirebaseException(FirebaseException e, {String? defaultMessage}) {
    String errorMessage = defaultMessage ?? 'An error occurred';

    switch (e.code) {
      case 'permission-denied':
        errorMessage =
            'Permission denied. You do not have access to this resource';
        break;
      case 'unavailable':
        errorMessage =
            'Service is currently unavailable. Please try again later';
        break;
      case 'deadline-exceeded':
        errorMessage = 'Request timed out. Please try again';
        break;
      case 'resource-exhausted':
        errorMessage = 'Resource limit exceeded. Please try again later';
        break;
      case 'not-found':
        errorMessage = 'Resource not found';
        break;
      case 'already-exists':
        errorMessage = 'Resource already exists';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Please check your connection';
        break;
      default:
        errorMessage =
            e.message ?? defaultMessage ?? 'An unexpected error occurred';
    }

    _showError('Error', errorMessage);
  }

  /// Shows error message using GetX snackbar
  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 4),
    );
  }
}
