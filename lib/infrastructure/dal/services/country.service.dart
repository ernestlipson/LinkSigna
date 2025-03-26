import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide Response;
import 'package:sign_language_app/infrastructure/dal/daos/models/location.model.dart';
import '../daos/models/flags.model.dart';

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
      await _checkLocationPermissions();
      final position = await _getCurrentPosition();
      return await _getCountryCodeFromPosition(position);
    } catch (error) {
      _logError('Failed to get user country code', error);
      return null;
    }
  }

  Future<void> _checkLocationPermissions() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw LocationServiceException('Location service is disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
          'Location permission is permanently denied');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!_isValidPermission(permission)) {
        throw LocationServiceException('Location permission denied');
      }
    }
  }

  bool _isValidPermission(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<Position> _getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<String?> _getCountryCodeFromPosition(Position position) async {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    return placemarks.first.isoCountryCode;
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
