import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../utils/phone_number.util.dart';

class FirebaseAuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables for UI updates
  final isPhoneAuthLoading = false.obs;
  final isOtpVerifying = false.obs;
  final isResendingOtp = false.obs;
  final canResendOtp = false.obs;
  final resendTimer = 60.obs;

  // Current user
  final currentUser = Rx<User?>(null);

  // Verification ID for OTP
  String? _verificationId;
  String? _phoneNumber;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
    });
  }

  /// Request OTP for phone number
  Future<void> requestPhoneOTP(String phoneNumber) async {
    isPhoneAuthLoading.value = true;

    // Ensure phone number is in E.164 format
    String formattedPhoneNumber = phoneNumber;
    if (!phoneNumber.startsWith('+')) {
      formattedPhoneNumber = '+233$phoneNumber'; // Default to Ghana
    }
    _phoneNumber = formattedPhoneNumber;

    try {
      print('Requesting OTP for phone: $formattedPhoneNumber');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          print('Auto-verification completed');
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          isPhoneAuthLoading.value = false;
          throw Exception('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OTP code sent to $phoneNumber');
          _verificationId = verificationId;
          isPhoneAuthLoading.value = false;
          startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('OTP auto-retrieval timeout');
          _verificationId = verificationId;
          isPhoneAuthLoading.value = false;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('Error requesting OTP: $e');
      isPhoneAuthLoading.value = false;
      rethrow;
    }
  }

  /// Verify OTP code
  Future<User?> verifyOTP(String otpCode) async {
    if (_verificationId == null) {
      throw Exception(
          'No verification ID available. Please request OTP first.');
    }

    isOtpVerifying.value = true;

    try {
      print('Verifying OTP: $otpCode');

      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      // Sign in with credential
      final user = await _signInWithCredential(credential);
      isOtpVerifying.value = false;
      return user;
    } catch (e) {
      print('Error verifying OTP: $e');
      isOtpVerifying.value = false;
      rethrow;
    }
  }

  /// Sign in with credential
  Future<User?> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      print('User signed in successfully: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      print('Error signing in with credential: $e');
      rethrow;
    }
  }

  /// Resend OTP
  Future<void> resendOTP() async {
    if (!canResendOtp.value || _phoneNumber == null) {
      throw Exception('Cannot resend OTP at this time');
    }

    isResendingOtp.value = true;

    try {
      print('Resending OTP to: $_phoneNumber');

      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Auto-verification completed on resend');
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Resend verification failed: ${e.message}');
          isResendingOtp.value = false;
          throw Exception('Resend verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OTP resent successfully');
          _verificationId = verificationId;
          isResendingOtp.value = false;
          startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('OTP auto-retrieval timeout on resend');
          _verificationId = verificationId;
          isResendingOtp.value = false;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('Error resending OTP: $e');
      isResendingOtp.value = false;
      rethrow;
    }
  }

  /// Start resend timer
  void startResendTimer() {
    canResendOtp.value = false;
    resendTimer.value = 60;

    // Countdown timer
    Stream.periodic(const Duration(seconds: 1), (i) => 60 - i - 1)
        .take(60)
        .listen((time) {
      resendTimer.value = time;
      if (time == 0) {
        canResendOtp.value = true;
      }
    });
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Get user ID
  String? getUserId() {
    return _auth.currentUser?.uid;
  }

  /// Get phone number
  String? getPhoneNumber() {
    return _auth.currentUser?.phoneNumber;
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      print('User account deleted successfully');
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}
