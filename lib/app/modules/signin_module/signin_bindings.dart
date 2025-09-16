import 'package:sign_language_app/app/modules/signin_module/signin_controller.dart';
import 'package:get/get.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class signinBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => signinController());
  }
}