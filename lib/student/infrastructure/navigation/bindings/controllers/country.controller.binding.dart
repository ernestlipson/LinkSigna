import 'package:get/get.dart';

import '../../../../domain/repositories/country.repo.dart';
import '../../../../presentation/shared/controllers/country.controller.dart';

class CountryControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CountryRepository>(
      () => CountryRepository(),
    );
    Get.lazyPut<CountryController>(
      () => CountryController(),
    );
  }
}
