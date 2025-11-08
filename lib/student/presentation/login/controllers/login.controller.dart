import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/infrastructure/navigation/routes.dart';
import 'package:sign_language_app/infrastructure/dal/services/student_user.firestore.service.dart';
import 'package:sign_language_app/student/presentation/shared/controllers/student_user.controller.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import 'package:sign_language_app/infrastructure/dal/services/firebase.exception.dart';
import '../../../../../infrastructure/mixins/country_flag_loader.mixin.dart';
import '../../../../shared/mixins/login.mixin.dart';

class LoginController extends GetxController
    with CountryFlagLoader, LoginMixin, FirebaseExceptionMixin {
  final RxBool isGoogleSignInLoading = false.obs;

  // Email/Password Authentication
  Future<void> login() async {
    if (!validateAll()) {
      showValidationErrors();
      return;
    }

    isLoading.value = true;
    try {
      // Sign in with email and password
      final credential = await signInWithEmailPassword();

      // Load complete user profile from Firestore
      final studentService = Get.find<StudentUserFirestoreService>();
      final userProfile =
          await studentService.findByAuthUid(credential.user!.uid);

      // Save user data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', emailController.text.trim());
      await prefs.setString('userName',
          userProfile?.displayName ?? credential.user?.displayName ?? 'User');
      await prefs.setBool('student_logged_in', true);

      if (userProfile != null) {
        await prefs.setString('university', userProfile.university ?? '');

        // Update StudentUserController if registered
        if (Get.isRegistered<StudentUserController>()) {
          Get.find<StudentUserController>().current.value = userProfile;
        }
      }

      // Save remember me preference (persist email only)
      await saveRememberedEmail(
        'remembered_email',
        emailController.text.trim(),
        remember: isRememberMe.value,
      );

      AppSnackbar.success(
        title: 'Success',
        message: 'Login successful!',
      );

      // Navigate to home screen
      Get.offAllNamed(Routes.STUDENT_HOME);
    } on FirebaseAuthException catch (e) {
      handleFirebaseAuthException(e, defaultMessage: 'Login failed');
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Login failed: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    try {
      // Prefill remembered email
      await loadRememberedEmail('remembered_email');

      // Navigate if already signed in
      if (auth.currentUser != null) {
        Get.offAllNamed(Routes.STUDENT_HOME);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error checking auth status: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
    loadCountryFlag();
  }

  @override
  void onClose() {
    disposeControllers();
    super.onClose();
  }
}
