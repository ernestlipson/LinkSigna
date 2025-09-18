import 'package:get/get.dart';

import '../../../../presentation/chat/controllers/interpreter_chat.controller.dart';

class InterpreterChatControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InterpreterChatController>(
      () => InterpreterChatController(),
    );
  }
}
