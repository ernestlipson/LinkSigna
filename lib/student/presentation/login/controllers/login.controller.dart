import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/infrastructure/navigation/routes.dart';
import 'package:sign_language_app/infrastructure/dal/services/user.firestore.service.dart';
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
      final credential = await signInWithEmailPassword();

      final userService = Get.find<UserFirestoreService>();
      final userProfile = await userService.findByAuthUid(credential.user!.uid);

      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      if (!userProfile.isStudent) {
        await auth.signOut();
        AppSnackbar.error(
          title: 'Error',
          message: 'This account is not registered as a student',
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', emailController.text.trim());
      await prefs.setString('userName',
          userProfile.displayName ?? credential.user?.displayName ?? 'User');
      await prefs.setBool('student_logged_in', true);
      await prefs.setString('userRole', 'student');

      if (userProfile.university != null) {
        await prefs.setString('university', userProfile.university!);
      }

      await saveRememberedEmail(
        'remembered_email',
        emailController.text.trim(),
        remember: isRememberMe.value,
      );

      AppSnackbar.success(
        title: 'Success',
        message: 'Login successful!',
      );

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
