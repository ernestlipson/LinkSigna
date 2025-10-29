import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

import 'infrastructure/navigation/routes.dart';
import 'student/presentation/shared/controllers/user.controller.dart';

Future<String> initializeUserSession() async {
  final prefs = await SharedPreferences.getInstance();
  final hasInterpreterLoggedIn =
      prefs.getBool('interpreter_logged_in') ?? false;
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (!Get.isRegistered<UserController>()) {
    Get.put(UserController());
  }

  if (firebaseUser != null) {
    final userController = Get.find<UserController>();
    final userName = prefs.getString('userName') ?? 'User';
    userController.setUser(name: userName);
  }

  return getInitialRoute(
    hasInterpreterLoggedIn: hasInterpreterLoggedIn,
    isInterpreterAuthenticated: firebaseUser != null,
    isStudentLoggedIn: firebaseUser != null,
  );
}

String getInitialRoute({
  required bool hasInterpreterLoggedIn,
  required bool isInterpreterAuthenticated,
  required bool isStudentLoggedIn,
}) {
  if (hasInterpreterLoggedIn) {
    if (isInterpreterAuthenticated) {
      return Routes.INTERPRETER_HOME;
    } else {
      return Routes.INTERPRETER_SIGNIN;
    }
  } else if (isStudentLoggedIn) {
    return Routes.STUDENT_HOME;
  } else {
    return Routes.initialRoute;
  }
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    appleProvider: kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
  );

  try {
    await FirebaseAuth.instance.setLanguageCode('en');
  } catch (_) {}
}
