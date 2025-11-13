import 'package:get/get.dart';

import '../../../../../infrastructure/presentation/controllers/country.controller.dart';
import '../../../../presentation/home/controllers/home.controller.dart';
import '../../../../presentation/sessions/controllers/sessions.controller.dart';
import '../../../../presentation/shared/controllers/student_user.controller.dart';

class HomeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SessionsController>(() => SessionsController());
    Get.lazyPut<StudentUserController>(() => StudentUserController());
    Get.lazyPut<CountryController>(() => CountryController());
  }
}
