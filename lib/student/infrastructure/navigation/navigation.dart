import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'bindings/controllers/interpreters.controller.binding.dart';
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
    GetPage(
      name: StudentRoutes.HOME,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: StudentRoutes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginControllerBinding(),
    ),
    GetPage(
      name: StudentRoutes.SIGNUP,
      page: () => SignupScreen(),
      binding: SignupControllerBinding(),
    ),
    GetPage(
      name: StudentRoutes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordControllerBinding(),
    ),
    GetPage(
      name: StudentRoutes.OTP,
      page: () => const OtpScreen(),
      binding: OtpControllerBinding(),
    ),
    GetPage(
      name: StudentRoutes.INTERPRETERS,
      page: () => const InterpretersScreen(),
      binding: InterpretersControllerBinding(),
    ),
    GetPage(
      name: StudentRoutes.SESSIONS,
      page: () => const SessionsScreen(),
      binding: SessionsControllerBinding(),
    ),
    GetPage(
      name: StudentRoutes.DEAF_HISTORY,
      page: () => const DeafHistoryScreen(),
      binding: DeafHistoryControllerBinding(),
    ),
    GetPage(
      name: StudentRoutes.SETTINGS,
      page: () => const SettingsScreen(),
      binding: SettingsControllerBinding(),
    ),
  ];
}
