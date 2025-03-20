// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryFlags _$CountryFlagsFromJson(Map<String, dynamic> json) => CountryFlags(
      flags: Flags.fromJson(json['flags'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CountryFlagsToJson(CountryFlags instance) =>
    <String, dynamic>{
      'flags': instance.flags,
    };

Flags _$FlagsFromJson(Map<String, dynamic> json) => Flags(
      png: json['png'] as String,
      svg: json['svg'] as String,
      alt: json['alt'] as String,
    );

Map<String, dynamic> _$FlagsToJson(Flags instance) => <String, dynamic>{
      'png': instance.png,
      'svg': instance.svg,
      'alt': instance.alt,
    };
