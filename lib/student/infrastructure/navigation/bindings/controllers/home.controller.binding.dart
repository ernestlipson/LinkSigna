import 'package:get/get.dart';

import '../../../../presentation/home/controllers/home.controller.dart';
import '../../../../presentation/sessions/controllers/sessions.controller.dart';
import '../../../../presentation/shared/controllers/country.controller.dart';
import '../../../../presentation/shared/controllers/user.controller.dart';

class HomeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SessionsController>(() => SessionsController());
    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<CountryController>(() => CountryController());
  }
}
