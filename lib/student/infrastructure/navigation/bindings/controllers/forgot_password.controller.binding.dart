import 'package:get/get.dart';

import '../../../../presentation/forgot-password/controllers/forgot_password.controller.dart';
import 'country.controller.binding.dart';

class ForgotPasswordControllerBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize country controller binding first
    CountryControllerBinding().dependencies();

    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(),
    );
  }
}
