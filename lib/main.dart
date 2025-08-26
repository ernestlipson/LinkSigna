import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_otp/email_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'student/main.home.dart';
import 'interpreter/int.home.dart';
import 'student/infrastructure/navigation/routes.dart';
import 'student/infrastructure/navigation/bindings/global.binding.dart';
import 'student/infrastructure/navigation/navigation.dart';
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

  // Decide initial route based on login status or returning user flag
  final prefs = await SharedPreferences.getInstance();
  final seenOnboardingOrReturning =
      prefs.getBool('has_logged_in_before') ?? false;
  final initial = seenOnboardingOrReturning ? Routes.HOME : Routes.initialRoute;

  // Load user name and set it in UserController if user has logged in before
  if (seenOnboardingOrReturning) {
    final userName = prefs.getString('userName') ?? 'User';
    Get.put(UserController());
    final userController = Get.find<UserController>();
    userController.setUser(name: userName);
  }

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
      initialBinding: GlobalBinding(), // Add global binding
      initialRoute: initialRoute,
      getPages: Nav.routes,
    );
  }
}
