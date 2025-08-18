import 'package:get/get.dart';

import '../../../../presentation/interpreter/controllers/interpreter.controller.dart';

class InterpreterControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterpreterController>(
      () => InterpreterController(),
    );
  }
}
