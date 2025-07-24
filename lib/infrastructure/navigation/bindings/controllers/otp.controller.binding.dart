import 'package:get/get.dart';

import '../../../../presentation/otp/controllers/otp.controller.dart';

class OtpControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(
      () => OtpController(),
    );
  }
}
