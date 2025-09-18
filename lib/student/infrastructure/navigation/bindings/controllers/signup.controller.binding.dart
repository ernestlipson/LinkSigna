import 'package:get/get.dart';

import '../../../../presentation/signup/controllers/signup.controller.dart';
import 'country.controller.binding.dart';

class SignupControllerBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize country controller binding first
    CountryControllerBinding().dependencies();

    Get.lazyPut<SignupController>(
      () => SignupController(),
    );
  }
}
