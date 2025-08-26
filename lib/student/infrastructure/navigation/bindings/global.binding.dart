import 'package:get/get.dart';

import '../../../domain/repositories/country.repo.dart';
import '../../../presentation/shared/controllers/country.controller.dart';
import '../../../presentation/shared/controllers/user.controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    // Register country repository and controller
    Get.lazyPut<CountryRepository>(() => CountryRepository(), fenix: true);
    Get.lazyPut<CountryController>(() => CountryController(), fenix: true);
    // Register user controller globally
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
  }
}
