import 'package:json_annotation/json_annotation.dart';

part 'location.model.g.dart';

@JsonSerializable()
class LocationInfo {
  final String status;
  final String country;
  @JsonKey(name: 'countryCode')
  final String countryCode;
  final String region;
  @JsonKey(name: 'regionName')
  final String regionName;
  final String city;
  final String zip;
  final double lat;
  final double lon;
  final String timezone;
  final String isp;
  final String org;
  @JsonKey(name: 'as')
  final String asInfo;
  final String query;

  LocationInfo({
    required this.status,
    required this.country,
    required this.countryCode,
    required this.region,
    required this.regionName,
    required this.city,
    required this.zip,
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.isp,
    required this.org,
    required this.asInfo,
    required this.query,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) =>
      _$LocationInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LocationInfoToJson(this);
}
