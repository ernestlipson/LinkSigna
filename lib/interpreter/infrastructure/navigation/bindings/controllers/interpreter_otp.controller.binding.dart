import 'package:get/get.dart';

import '../../../../presentation/otp/controllers/interpreter_otp.controller.dart';

class InterpreterOtpControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterpreterOtpController>(
      () => InterpreterOtpController(),
    );
  }
}
