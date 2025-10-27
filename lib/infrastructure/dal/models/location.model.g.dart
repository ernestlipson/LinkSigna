// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationInfo _$LocationInfoFromJson(Map<String, dynamic> json) => LocationInfo(
      status: json['status'] as String,
      country: json['country'] as String,
      countryCode: json['countryCode'] as String,
      region: json['region'] as String,
      regionName: json['regionName'] as String,
      city: json['city'] as String,
      zip: json['zip'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      timezone: json['timezone'] as String,
      isp: json['isp'] as String,
      org: json['org'] as String,
      asInfo: json['as'] as String,
      query: json['query'] as String,
    );

const _$LocationInfoFieldMap = <String, String>{
  'status': 'status',
  'country': 'country',
  'countryCode': 'countryCode',
  'region': 'region',
  'regionName': 'regionName',
  'city': 'city',
  'zip': 'zip',
  'lat': 'lat',
  'lon': 'lon',
  'timezone': 'timezone',
  'isp': 'isp',
  'org': 'org',
  'asInfo': 'as',
  'query': 'query',
};

Map<String, dynamic> _$LocationInfoToJson(LocationInfo instance) =>
    <String, dynamic>{
      'status': instance.status,
      'country': instance.country,
      'countryCode': instance.countryCode,
      'region': instance.region,
      'regionName': instance.regionName,
      'city': instance.city,
      'zip': instance.zip,
      'lat': instance.lat,
      'lon': instance.lon,
      'timezone': instance.timezone,
      'isp': instance.isp,
      'org': instance.org,
      'as': instance.asInfo,
      'query': instance.query,
    };
