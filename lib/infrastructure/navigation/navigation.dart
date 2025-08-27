import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config.dart';
// Student imports
import '../../student/presentation/screens.dart';
import '../../student/infrastructure/navigation/bindings/controllers/home.controller.binding.dart';
import '../../student/infrastructure/navigation/bindings/controllers/login.controller.binding.dart';
import '../../student/infrastructure/navigation/bindings/controllers/signup.controller.binding.dart';
import '../../student/infrastructure/navigation/bindings/controllers/forgot_password.controller.binding.dart';
import '../../student/infrastructure/navigation/bindings/controllers/otp.controller.binding.dart';
import '../../student/infrastructure/navigation/bindings/controllers/interpreters.controller.binding.dart';
import '../../student/infrastructure/navigation/bindings/controllers/sessions.controller.binding.dart';
import '../../student/infrastructure/navigation/bindings/controllers/deaf_history.controller.binding.dart';
import '../../student/infrastructure/navigation/bindings/controllers/settings.controller.binding.dart';
// Interpreter imports
import '../../interpreter/presentation/screens.dart';
import '../../interpreter/infrastructure/navigation/bindings/controllers/inteerpreter.controller.binding.dart';
import '../../interpreter/infrastructure/navigation/bindings/controllers/interpreter.controller.binding.dart';
import '../../interpreter/infrastructure/navigation/bindings/controllers/interpreter_otp.controller.binding.dart';
import '../../interpreter/infrastructure/navigation/bindings/controllers/interpreter_home.controller.binding.dart';
import '../../interpreter/infrastructure/navigation/bindings/controllers/interpreter_chat.controller.binding.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  const EnvironmentsBadge({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: env!,
            color: env == Environments.QAS ? Colors.blue : Colors.purple,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    // Student Routes
    GetPage(
      name: Routes.STUDENT_HOME,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: Routes.STUDENT_LOGIN,
      page: () => const LoginScreen(),
      binding: LoginControllerBinding(),
    ),
    GetPage(
      name: Routes.STUDENT_SIGNUP,
      page: () => SignupScreen(),
      binding: SignupControllerBinding(),
    ),
    GetPage(
      name: Routes.STUDENT_FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordControllerBinding(),
    ),
    GetPage(
      name: Routes.STUDENT_OTP,
      page: () => const OtpScreen(),
      binding: OtpControllerBinding(),
    ),
    GetPage(
      name: Routes.STUDENT_INTERPRETERS,
      page: () => const InterpretersScreen(),
      binding: InterpretersControllerBinding(),
    ),
    GetPage(
      name: Routes.STUDENT_SESSIONS,
      page: () => const SessionsScreen(),
      binding: SessionsControllerBinding(),
    ),
    GetPage(
      name: Routes.STUDENT_DEAF_HISTORY,
      page: () => const DeafHistoryScreen(),
      binding: DeafHistoryControllerBinding(),
    ),
    GetPage(
      name: Routes.STUDENT_SETTINGS,
      page: () => const SettingsScreen(),
      binding: SettingsControllerBinding(),
    ),

    // Interpreter Routes
    GetPage(
      name: Routes.INTERPRETER_SIGNUP,
      page: () => const InterpreterSignupScreen(),
      binding: InterpreterSignupControllerBinding(),
    ),
    GetPage(
      name: Routes.INTERPRETER_OTP,
      page: () => const InterpreterOtpScreen(),
      binding: InterpreterOtpControllerBinding(),
    ),
    GetPage(
      name: Routes.INTERPRETER_HOME,
      page: () => const InterpreterHomeScreen(),
      binding: InterpreterHomeControllerBinding(),
    ),
    GetPage(
      name: Routes.INTERPRETER_CHAT,
      page: () => const InterpreterChatScreen(),
      binding: InterpreterChatControllerBinding(),
    ),
    GetPage(
      name: Routes.INTERPRETER,
      page: () => const InterpreterScreen(),
      binding: InterpreterControllerBinding(),
    ),
  ];
}
