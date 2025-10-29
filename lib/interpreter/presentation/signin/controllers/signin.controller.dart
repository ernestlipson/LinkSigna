import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/services/interpreter_user.firestore.service.dart';
import '../../../../domain/users/interpreter_user.model.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import '../../../../shared/mixins/login.mixin.dart';

class InterpreterSigninController extends GetxController with LoginMixin {
  final isSubmitting = false.obs;

  // Services
  final InterpreterUserFirestoreService _firestoreService =
      Get.find<InterpreterUserFirestoreService>();

  Future<void> login() async {
    if (!validateAll()) {
      showValidationErrors();
      return;
    }

    isSubmitting.value = true;

    try {
      final credential = await signInWithEmailPassword();

      final profile = await _loadInterpreterProfile(credential.user);

      if (profile == null) {
        await auth.signOut();
        AppSnackbar.error(
          title: 'Profile Missing',
          message: 'Interpreter profile not found for this account.',
        );
        return;
      }

      await _cacheSession(profile, rememberEmail: isRememberMe.value);

      if (Get.isRegistered<InterpreterProfileController>()) {
        Get.find<InterpreterProfileController>().setProfile(profile);
      }

      AppSnackbar.success(
        title: 'Success',
        message: 'Login successful!',
      );

      Get.offAllNamed(Routes.INTERPRETER_HOME);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(
        title: 'Login Failed',
        message: mapAuthError(e),
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Login failed: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _prefillRememberedEmail() async {
    await loadRememberedEmail('interpreter_remembered_email');
  }

  Future<void> _checkAuthStatus() async {
    final user = auth.currentUser;
    if (user == null) return;

    try {
      final profile = await _loadInterpreterProfile(user);
      if (profile == null) return;

      await _cacheSession(profile, rememberEmail: isRememberMe.value);

      if (Get.isRegistered<InterpreterProfileController>()) {
        Get.find<InterpreterProfileController>().setProfile(profile);
      }

      Get.offAllNamed(Routes.INTERPRETER_HOME);
    } catch (e) {
      Get.log('Interpreter auto-login failed: $e');
    }
  }

  Future<InterpreterUser?> _loadInterpreterProfile(User? user) async {
    if (user == null) return null;

    final byAuth = await _firestoreService.findByAuthUid(user.uid);
    if (byAuth != null) return byAuth;

    final email = user.email ?? emailController.text.trim();
    if (email.isEmpty) return null;

    final byEmail = await _firestoreService.findByEmail(email);
    if (byEmail != null) {
      await _firestoreService.updateFields(byEmail.interpreterID, {
        'authUid': user.uid,
      });
      return byEmail.copyWith(authUid: user.uid);
    }

    if (user.displayName != null) {
      final parts = user.displayName!.trim().split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      return _firestoreService.getOrCreateByAuthUid(
        authUid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
    }

    return _firestoreService.getOrCreateByAuthUid(
      authUid: user.uid,
      email: email,
      firstName: '',
      lastName: '',
    );
  }

  Future<void> _cacheSession(InterpreterUser profile,
      {required bool rememberEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('interpreter_logged_in', true);
    await prefs.setString('interpreter_email', profile.email);
    await prefs.setString('interpreter_name', profile.displayName.trim());
    await prefs.setString('interpreter_id', profile.interpreterID);
    if (profile.university != null && profile.university!.isNotEmpty) {
      await prefs.setString('university', profile.university!);
    }

    await saveRememberedEmail(
      'interpreter_remembered_email',
      profile.email,
      remember: rememberEmail,
    );

    if (rememberEmail) {
      emailController.text = profile.email;
      isRememberMe.value = true;
    } else {
      isRememberMe.value = false;
    }
  }

  @override
  void onClose() {
    disposeControllers();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _prefillRememberedEmail();
    await _checkAuthStatus();
  }
}
