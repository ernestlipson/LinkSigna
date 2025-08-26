import 'package:get/get.dart';

import '../../../../presentation/deaf-history/controllers/deaf_history.controller.dart';

class DeafHistoryControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeafHistoryController>(
      () => DeafHistoryController(),
    );
  }
}
