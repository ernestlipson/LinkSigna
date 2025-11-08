import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import '../../domain/entities/flag.entity.dart';
import '../../domain/repositories/country.repository.dart';

class CountryController extends GetxController {
  static CountryController get instance => Get.find();
  static const String defaultFlagUrl = 'https://flagcdn.com/w40/gh.png';

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
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to fetch country flag',
      );
    } finally {
      countryLoading.value = false;
    }
  }

  Future<void> refreshCountryFlag() async {
    await fetchCountryFlag();
  }

  String get currentFlagUrl => countryFlag.value?.png ?? defaultFlagUrl;

  Future<String> loadFlagUrl({bool forceRefresh = false}) async {
    if (forceRefresh || countryFlag.value == null) {
      await fetchCountryFlag();
    }
    return currentFlagUrl;
  }
}
