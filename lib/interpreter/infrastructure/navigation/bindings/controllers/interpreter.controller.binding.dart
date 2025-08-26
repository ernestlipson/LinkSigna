import 'package:get/get.dart';

import '../../../../presentation/main/controllers/interpreter.controller.dart';

class InterpreterControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterpreterController>(
      () => InterpreterController(),
    );
  }
}
