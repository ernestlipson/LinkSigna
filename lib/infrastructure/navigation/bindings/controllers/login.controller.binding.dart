import 'package:get/get.dart';

import '../../../../presentation/login/controllers/login.controller.dart';

class LoginControllerBinding extends Bindings {
  @override
  void dependencies() {
    // Register login controller (auth dependencies are available globally)
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
