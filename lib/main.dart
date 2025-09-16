import 'package:email_otp/email_otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'infrastructure/theme/app_theme.dart';
import 'student/infrastructure/navigation/bindings/global.binding.dart';
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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final hasStudentLoggedIn = prefs.getBool('student_logged_in') ?? false;
  final hasInterpreterLoggedIn =
      prefs.getBool('interpreter_logged_in') ?? false;

  final initial = hasInterpreterLoggedIn
      ? Routes.INTERPRETER_HOME
      : hasStudentLoggedIn
          ? Routes.STUDENT_HOME
          : Routes.initialRoute;

  if (!Get.isRegistered<UserController>()) {
    Get.put(UserController());
  }
  if (hasStudentLoggedIn) {
    final userController = Get.find<UserController>();
    userController.setUser(name: prefs.getString('userName') ?? 'User');
  }

  runApp(Main(initialRoute: initial));
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialBinding: GlobalBinding(),
      initialRoute: initialRoute,
      getPages: Nav.routes,
    );
  }
}
