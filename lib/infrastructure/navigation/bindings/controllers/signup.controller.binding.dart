import 'package:get/get.dart';

import '../../../../domain/repositories/country.repo.dart';
import '../../../../presentation/signup/controllers/signup.controller.dart';

class SignupControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(
      () => SignupController(),
    );
    Get.lazyPut<CountryRepository>(
      () => CountryRepository(),
    );
  }
}
