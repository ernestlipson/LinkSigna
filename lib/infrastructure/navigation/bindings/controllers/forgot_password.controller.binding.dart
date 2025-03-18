import 'package:get/get.dart';

import '../../../../presentation/forgot-password/controllers/forgot_password.controller.dart';

class ForgotPasswordControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(),
    );
  }
}
