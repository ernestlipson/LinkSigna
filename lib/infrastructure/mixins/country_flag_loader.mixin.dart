import 'package:get/get.dart';
import '../presentation/controllers/country.controller.dart';

mixin CountryFlagLoader on GetxController {
  final RxBool isLoadingFlag = false.obs;
  final RxString countryFlagUrl = CountryController.defaultFlagUrl.obs;

  CountryController get countryController => CountryController.instance;

  Future<void> loadCountryFlag({bool forceRefresh = false}) async {
    try {
      isLoadingFlag.value = true;
      countryFlagUrl.value = await countryController.loadFlagUrl(
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      countryFlagUrl.value = CountryController.defaultFlagUrl;
      Get.log('Country flag load failed: $e');
    } finally {
      isLoadingFlag.value = false;
    }
  }
}
