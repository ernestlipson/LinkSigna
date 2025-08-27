import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'infrastructure/navigation/routes.dart';
import 'student/infrastructure/navigation/bindings/global.binding.dart';
import 'infrastructure/navigation/navigation.dart';
import 'student/infrastructure/theme/app_theme.dart';
import 'student/presentation/shared/controllers/user.controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EmailOTP.config(
    appName: 'LinkSigna',
    otpType: OTPType.numeric,
    expiry: 300000, // 5 minutes
    emailTheme: EmailTheme.v6,
    appEmail: 'noreply@linksigna.com',
    otpLength: 6,
  );

  final prefs = await SharedPreferences.getInstance();

  // Check for both student and interpreter login status
  final hasStudentLoggedIn = prefs.getBool('student_logged_in') ?? false;
  final hasInterpreterLoggedIn =
      prefs.getBool('interpreter_logged_in') ?? false;

  // Determine initial route based on login status
  String initial;
  if (hasInterpreterLoggedIn) {
    initial = Routes.INTERPRETER_HOME;
  } else if (hasStudentLoggedIn) {
    initial = Routes.STUDENT_HOME;
  } else {
    initial = Routes.initialRoute;
  }

  // Set up user controller if any user is logged in
  if (hasStudentLoggedIn || hasInterpreterLoggedIn) {
    final userName = prefs.getString('userName') ?? 'User';
    Get.put(UserController());
    final userController = Get.find<UserController>();
    userController.setUser(name: userName);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(Main(initialRoute: initial));
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: appTheme.copyWith(
          textTheme: appTheme.textTheme.apply(
        fontFamily: 'WorkSans',
      )),
      initialBinding: GlobalBinding(),
      initialRoute: initialRoute,
      getPages: Nav.routes,
    );
  }
}
