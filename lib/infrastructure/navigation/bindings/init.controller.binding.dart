import 'package:get/get.dart';

import '../../../shared/controllers/init.controller.dart';

class InitControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<InitController>(InitController());
  }
}
