import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'infrastructure/dal/services/user.firestore.service.dart';
import 'infrastructure/navigation/routes.dart';

Future<String> initializeUserSession() async {
  final prefs = await SharedPreferences.getInstance();
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser != null) {
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
      // Handle error appropriately
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
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
    );
  }

  try {
    await FirebaseAuth.instance.setLanguageCode('en');
  } catch (e) {
    // Handle error appropriately
  }
}
