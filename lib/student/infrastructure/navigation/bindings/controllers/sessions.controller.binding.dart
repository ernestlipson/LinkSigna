import 'package:get/get.dart';

import '../../../../presentation/sessions/controllers/sessions.controller.dart';

class SessionsControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SessionsController>(
      () => SessionsController(),
    );
  }
}
