import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/services/interpreter_user.firestore.service.dart';
import '../../../../shared/mixins/signup.mixin.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

class InterpreterSignupController extends GetxController with SignupMixin {
  @override
  final isSubmitting = false.obs;

  Future<void> submit() async {
    if (!validateAll()) {
      if (!isTermsAccepted.value) {
        showTermsRequiredError();
      }
      return;
    }

    isSubmitting.value = true;
    try {
      // Create Firebase Auth user
      final credential = await createFirebaseAuthUser();

      // Parse name into first and last name
      final nameParts = parseFullName(nameController.text);
      final firstName = nameParts['firstName']!;
      final lastName = nameParts['lastName']!;

      // Create Firestore interpreter profile
      final interpreterService = Get.find<InterpreterUserFirestoreService>();
      await interpreterService.getOrCreateByAuthUid(
        authUid: credential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: emailController.text.trim(),
        university: selectedUniversity.value,
      );

      // Store session in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('interpreter_logged_in', true);
      await prefs.setString('interpreter_email', emailController.text.trim());
      await prefs.setString('interpreter_name', nameController.text.trim());
      await prefs.setString('university', selectedUniversity.value);

      AppSnackbar.success(
        title: 'Success',
        message: 'Account created successfully!',
      );

      // Navigate directly to interpreter home
      Get.offAllNamed(Routes.INTERPRETER_HOME);
    } on FirebaseAuthException catch (e) {
      showFirebaseAuthError(e.code);
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    disposeControllers();
    super.onClose();
  }
}
