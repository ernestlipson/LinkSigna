import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'infrastructure/navigation/routes.dart';
import 'student/presentation/shared/controllers/user.controller.dart';

/// Initialize user session and determine the initial route
///
/// This function handles:
/// - Checking interpreter login status from SharedPreferences
/// - Verifying Firebase authentication state
/// - Initializing the UserController
/// - Setting user information if logged in
/// - Determining the appropriate initial route based on user type
Future<String> initializeUserSession() async {
  final prefs = await SharedPreferences.getInstance();
  final hasInterpreterLoggedIn =
      prefs.getBool('interpreter_logged_in') ?? false;
  final firebaseUser = FirebaseAuth.instance.currentUser;

  // Initialize UserController if not already registered
  if (!Get.isRegistered<UserController>()) {
    Get.put(UserController());
  }

  // Set user information if authenticated
  if (firebaseUser != null) {
    final userController = Get.find<UserController>();
    final userName = prefs.getString('userName') ?? 'User';
    userController.setUser(name: userName);
  }

  // Determine initial route based on authentication state
  return getInitialRoute(
    hasInterpreterLoggedIn: hasInterpreterLoggedIn,
    isStudentLoggedIn: firebaseUser != null,
  );
}

/// Determine the initial route based on user authentication state
///
/// Priority:
/// 1. Interpreter home if interpreter is logged in
/// 2. Student home if student is logged in via Firebase
/// 3. Default initial route (landing/login page) if no user is logged in
String getInitialRoute({
  required bool hasInterpreterLoggedIn,
  required bool isStudentLoggedIn,
}) {
  if (hasInterpreterLoggedIn) {
    return Routes.INTERPRETER_HOME;
  } else if (isStudentLoggedIn) {
    return Routes.STUDENT_HOME;
  } else {
    return Routes.initialRoute;
  }
}
