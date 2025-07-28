import 'package:get/get.dart';

import '../../../../presentation/otp/controllers/otp.controller.dart';

class OtpControllerBinding extends Bindings {
  @override
  void dependencies() {
    // Register OTP controller (auth dependencies are available globally)
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
