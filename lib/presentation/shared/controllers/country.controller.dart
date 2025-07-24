import 'package:get/get.dart';

import '../../../domain/entities/flag.entity.dart';
import '../../../domain/repositories/country.repo.dart';

class CountryController extends GetxController {
  static CountryController get instance => Get.find();

  final CountryRepository _countryRepository = CountryRepository.instance;

  final countryLoading = false.obs;
  final Rx<Flag?> countryFlag = Rx<Flag?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchCountryFlag();
  }

  Future<void> fetchCountryFlag() async {
    try {
      countryLoading.value = true;
      final flag = await _countryRepository.getCountryFlag();
      countryFlag.value = flag;
    } catch (e, s) {
      Get.log("Fetch Flag: $e $s");
      Get.snackbar('Error', 'Failed to fetch country flag',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      countryLoading.value = false;
    }
  }

  Future<void> refreshCountryFlag() async {
    await fetchCountryFlag();
  }
}
