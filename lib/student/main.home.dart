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
      initialRoute: StudentRoutes.LOGIN,
      getPages: [
        GetPage(
          name: StudentRoutes.LOGIN,
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: StudentRoutes.SIGNUP,
          page: () => SignupScreen(),
        ),
        GetPage(
          name: StudentRoutes.FORGOT_PASSWORD,
          page: () => const ForgotPasswordScreen(),
        ),
        GetPage(
          name: StudentRoutes.OTP,
          page: () => const OtpScreen(),
        ),
        GetPage(
          name: StudentRoutes.HOME,
          page: () => const HomeScreen(),
        ),
      ],
    );
  }
}
