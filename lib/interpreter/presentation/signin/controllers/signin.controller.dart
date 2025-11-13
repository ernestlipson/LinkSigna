import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/dal/services/user.firestore.service.dart';
import '../../../../domain/users/user.model.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import '../../../../shared/mixins/login.mixin.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';

class InterpreterSigninController extends GetxController with LoginMixin {
  final isSubmitting = false.obs;

  final UserFirestoreService _userService = Get.find<UserFirestoreService>();

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
        await auth.FirebaseAuth.instance.signOut();
        AppSnackbar.error(
          title: 'Profile Missing',
          message: 'Interpreter profile not found for this account.',
        );
        return;
      }

      if (!profile.isInterpreter) {
        await auth.FirebaseAuth.instance.signOut();
        AppSnackbar.error(
          title: 'Error',
          message: 'This account is not registered as an interpreter',
        );
        return;
      }

      await _cacheSession(profile, rememberEmail: isRememberMe.value);

      // Set profile in InterpreterProfileController
      if (Get.isRegistered<InterpreterProfileController>()) {
        Get.find<InterpreterProfileController>().setProfile(profile);
      }

      AppSnackbar.success(
        title: 'Success',
        message: 'Login successful!',
      );

      Get.offAllNamed(Routes.INTERPRETER_HOME);
    } on auth.FirebaseAuthException catch (e) {
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
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final profile = await _loadInterpreterProfile(user);
      if (profile == null || !profile.isInterpreter) return;

      await _cacheSession(profile, rememberEmail: isRememberMe.value);

      // Set profile in InterpreterProfileController
      if (Get.isRegistered<InterpreterProfileController>()) {
        Get.find<InterpreterProfileController>().setProfile(profile);
      }

      Get.offAllNamed(Routes.INTERPRETER_HOME);
    } catch (e) {
      Get.log('Interpreter auto-login failed: $e');
    }
  }

  Future<User?> _loadInterpreterProfile(auth.User? user) async {
    if (user == null) return null;

    var profile = await _userService.findByAuthUid(user.uid);
    if (profile != null && profile.isInterpreter) return profile;

    final email = user.email ?? emailController.text.trim();
    if (email.isEmpty) return null;

    profile = await _userService.findByEmail(email);
    if (profile != null && profile.isInterpreter) {
      await _userService.updateFields(profile.uid, {'authUid': user.uid});
      return profile.copyWith(authUid: user.uid);
    }

    if (user.displayName != null) {
      final parts = user.displayName!.trim().split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      return _userService.getOrCreateInterpreter(
        authUid: user.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
    }

    return _userService.getOrCreateInterpreter(
      authUid: user.uid,
      firstName: '',
      lastName: '',
      email: email,
    );
  }

  Future<void> _cacheSession(User profile,
      {required bool rememberEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('interpreter_logged_in', true);
    await prefs.setString('interpreter_email', profile.email ?? '');
    await prefs.setString(
        'interpreter_name', profile.displayName?.trim() ?? '');
    await prefs.setString('interpreter_id', profile.uid);
    await prefs.setString('userRole', 'interpreter');
    if (profile.university != null && profile.university!.isNotEmpty) {
      await prefs.setString('university', profile.university!);
    }

    await saveRememberedEmail(
      'interpreter_remembered_email',
      profile.email ?? '',
      remember: rememberEmail,
    );

    if (rememberEmail && profile.email != null) {
      emailController.text = profile.email!;
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
