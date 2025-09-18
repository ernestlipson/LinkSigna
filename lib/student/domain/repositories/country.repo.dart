import 'package:get/get.dart';
import '../../infrastructure/dal/services/country.service.dart';

import '../entities/flag.entity.dart';

class CountryRepository {
  static CountryRepository get instance => Get.find();
  final CountryService _dataSource = CountryService.into;

  Future<Flag> getCountryFlag({String? countryCode}) async {
    final flags = await _dataSource.getCountryFlag();
    return Flag(
      png: flags.png,
      svg: flags.svg,
      alt: flags.alt,
    );
  }
}
