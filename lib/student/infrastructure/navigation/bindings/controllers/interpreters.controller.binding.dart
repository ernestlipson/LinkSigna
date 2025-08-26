import 'package:get/get.dart';

import '../../../../presentation/interpreters/controllers/interpreters.controller.dart';

class InterpretersControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterpretersController>(
      () => InterpretersController(),
    );
  }
}
