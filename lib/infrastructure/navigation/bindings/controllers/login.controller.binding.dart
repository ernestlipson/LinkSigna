import 'package:get/get.dart';

import '../../../../presentation/login/controllers/login.controller.dart';
import 'country.controller.binding.dart';

class LoginControllerBinding extends Bindings {
  @override
  void dependencies() {
    CountryControllerBinding().dependencies();

    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}
