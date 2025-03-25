import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/dal/services/network/base.network.dart';

import '../daos/models/flags.model.dart';

class CountryService extends BaseNetwork {
  static CountryService get instance => Get.find();
  static CountryService get into => Get.put(CountryService());
  final Dio _dio = Dio();

  CountryService() {
    _dio.options.baseUrl = 'https://restcountries.com/v3.1/';
  }

  Future<Flags> getCountry({String? countryCode}) async {
    try {
      final userCountry = await _getUserCountry();
      if (userCountry != null) countryCode = userCountry;
      final response = await _dio.get(
        'alpha/$countryCode?fields=flags',
      );
      if (response.statusCode == 200) {
        final data = response.data['flags'];
        return Flags.fromJson(data);
      } else {
        throw Exception('Failed to get country');
      }
    } catch (e) {
      throw Exception('Failed to get country');
    }
  }

  Future<String?> _getUserCountry() async {
    try {
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      Get.log('Location service is enabled: $isServiceEnabled');
      if (!isServiceEnabled) throw Exception('Location service is disabled');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is denied forever');
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception('Location permission is denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ));

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Get.log('Position Placemarks: $position $placemarks');
      final countryCode = placemarks.first.isoCountryCode;
      Get.log('User country code: $countryCode');
      if (countryCode != null) return countryCode;
    } catch (e) {
      throw Exception('Failed to get user country');
    }
    return null;
  }
}
