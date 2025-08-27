import 'package:get/get.dart';

import '../../../../presentation/home/controllers/interpreter_home.controller.dart';

class InterpreterHomeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterpreterHomeController>(
      () => InterpreterHomeController(),
    );
  }
}
