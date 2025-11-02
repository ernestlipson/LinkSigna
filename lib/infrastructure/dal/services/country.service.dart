import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../models/location.model.dart';
import '../models/flags.model.dart';

class CountryService {
  static CountryService get instance => Get.find();
  static CountryService get into => Get.put(CountryService());

  static const _baseRestCountriesUrl = 'https://restcountries.com/v3.1/alpha/';
  static const _baseLocationUrl = 'http://ip-api.com/';

  final Dio _dio;

  CountryService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Flags> getCountryFlag() async {
    try {
      final userLocation = await _fetchLocationInfo();
      final countryCode = userLocation.countryCode.toLowerCase();
      final flags = await _fetchCountryFlags(countryCode);
      return flags;
    } catch (error, stackTrace) {
      _logError('Error getting country flag', error, stackTrace);
      throw CountryServiceException('Failed to get country flag', error);
    }
  }

  Future<Flags> _fetchCountryFlags(String countryCode) async {
    final url = '$_baseRestCountriesUrl$countryCode?fields=flags';
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      return Flags.fromJson(response.data['flags']);
    }
    throw CountryServiceException('Failed to fetch country flags');
  }

  Future<String?> getUserCountryCode() async {
    try {
      final userLocation = await _fetchLocationInfo();
      return userLocation.countryCode;
    } catch (error) {
      _logError('Failed to get user country code', error);
      return null;
    }
  }

  Future<LocationInfo> _fetchLocationInfo() async {
    final response = await _dio.get('$_baseLocationUrl/json');

    if (response.statusCode == 200) {
      return LocationInfo.fromJson(response.data);
    }
    throw CountryServiceException('Failed to fetch location info');
  }

  void _logError(String message, dynamic error, [StackTrace? stackTrace]) {
    Get.log('$message: $error ${stackTrace ?? ''}');
  }
}

class CountryServiceException implements Exception {
  final String message;
  final dynamic cause;

  CountryServiceException(this.message, [this.cause]);

  @override
  String toString() => 'CountryServiceException: $message';
}

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
