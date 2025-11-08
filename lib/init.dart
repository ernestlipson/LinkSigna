import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

import 'infrastructure/navigation/routes.dart';
import 'infrastructure/dal/services/user.firestore.service.dart';
import 'student/presentation/shared/controllers/user.controller.dart';

Future<String> initializeUserSession() async {
  final prefs = await SharedPreferences.getInstance();
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (!Get.isRegistered<UserController>()) {
    Get.put(UserController());
  }

  if (firebaseUser != null) {
    final userController = Get.find<UserController>();
    final userName = prefs.getString('userName') ?? 'User';
    userController.setUser(name: userName);

    try {
      if (Get.isRegistered<UserFirestoreService>()) {
        final userService = Get.find<UserFirestoreService>();
        final role = await userService.getUserRole(firebaseUser.uid);

        if (role != null) {
          if (role == 'interpreter') {
            return Routes.INTERPRETER_HOME;
          } else if (role == 'student') {
            return Routes.STUDENT_HOME;
          }
        }
      }
    } catch (e) {
      Get.log('Error getting user role: $e');
    }
  }

  final storedRole = prefs.getString('userRole');
  if (storedRole == 'interpreter') {
    return Routes.INTERPRETER_SIGNIN;
  } else if (storedRole == 'student') {
    return Routes.STUDENT_LOGIN;
  }

  return Routes.initialRoute;
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate App Check
  if (kDebugMode) {
    try {
      // Use the debug provider in debug mode.
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );

      // Wait a moment for activation to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Get and log the token immediately
      final token = await FirebaseAppCheck.instance.getToken();
      if (token != null) {
        Get.log('========================================');
        Get.log('App Check Debug Token: $token');
        Get.log('Copy this EXACT token to Firebase Console');
        Get.log(
            'Firebase Console → App Check → Apps → Your Android App → Manage debug tokens');
        Get.log('========================================');
      } else {
        Get.log('WARNING: App Check token is null!');
      }

      // Listen for token changes
      FirebaseAppCheck.instance.onTokenChange.listen((token) {
        if (token != null) {
          Get.log('App Check Token Changed: $token');
        }
      });
    } catch (e) {
      Get.log('ERROR activating App Check: $e');
      Get.log('App Check is enabled but failing. You may need to:');
      Get.log(
          '1. Disable App Check enforcement in Firebase Console (APIs tab)');
      Get.log('2. Or properly register the debug token');
    }
  } else {
    // Use the production providers in release mode.
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
    );
  }

  try {
    await FirebaseAuth.instance.setLanguageCode('en');
  } catch (e) {
    Get.log('Failed to set FirebaseAuth language code: $e');
  }
}
