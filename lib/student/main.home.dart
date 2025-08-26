import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'presentation/home/home.screen.dart';
import 'presentation/login/login.screen.dart';
import 'presentation/signup/signup.screen.dart';
import 'presentation/forgot-password/forgot_password.screen.dart';
import 'presentation/otp/otp.screen.dart';
import 'infrastructure/navigation/routes.dart';
import 'infrastructure/navigation/bindings/global.binding.dart';

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LinkSigna Student',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: GlobalBinding(),
      initialRoute: Routes.LOGIN,
      getPages: [
        GetPage(
          name: Routes.LOGIN,
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: Routes.SIGNUP,
          page: () => SignupScreen(),
        ),
        GetPage(
          name: Routes.FORGOT_PASSWORD,
          page: () => const ForgotPasswordScreen(),
        ),
        GetPage(
          name: Routes.OTP,
          page: () => const OtpScreen(),
        ),
        GetPage(
          name: Routes.HOME,
          page: () => const HomeScreen(),
        ),
      ],
    );
  }
}
