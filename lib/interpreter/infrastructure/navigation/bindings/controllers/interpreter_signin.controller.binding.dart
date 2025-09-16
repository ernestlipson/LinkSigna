import 'package:get/get.dart';

import '../../../../presentation/signin/controllers/signin.controller.dart';

class InterpreterSigninControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterpreterSigninController>(
      () => InterpreterSigninController(),
    );
  }
}
