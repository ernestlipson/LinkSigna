import 'package:get/get.dart';

import '../../../../presentation/signup/controllers/interpreter.controller.dart';

class InteerpreterControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterpreterController>(
      () => InterpreterController(),
    );
  }
}
