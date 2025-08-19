import 'package:get/get.dart';

import '../../../../presentation/interpreter-signup/controllers/inteerpreter.controller.dart';

class InteerpreterControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InteerpreterController>(
      () => InteerpreterController(),
    );
  }
}
