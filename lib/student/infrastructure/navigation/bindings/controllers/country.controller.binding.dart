import 'package:get/get.dart';

import '../../../../../infrastructure/domain/repositories/country.repository.dart';
import '../../../../../infrastructure/presentation/controllers/country.controller.dart';

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
