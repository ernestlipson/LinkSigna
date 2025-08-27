import 'package:get/get.dart';

import '../../../../presentation/signup/controllers/interpreter.controller.dart';

class InterpreterSignupControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterpreterSignupController>(
      () => InterpreterSignupController(),
    );
  }
}
