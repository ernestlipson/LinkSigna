import 'package:get/get.dart';

import '../../../../presentation/messages/controllers/interpreter_messages.controller.dart';

class InterpreterMessagesControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterpreterMessagesController>(
      () => InterpreterMessagesController(),
    );
  }
}
