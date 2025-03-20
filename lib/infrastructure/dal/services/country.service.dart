import 'package:json_annotation/json_annotation.dart';

part 'country.service.g.dart';

@JsonSerializable()
class CountryFlags {
  final Flags flags;

  CountryFlags({required this.flags});

  factory CountryFlags.fromJson(Map<String, dynamic> json) =>
      _$CountryFlagsFromJson(json);

  Map<String, dynamic> toJson() => _$CountryFlagsToJson(this);
}

@JsonSerializable()
class Flags {
  final String png;
  final String svg;
  final String alt;

  Flags({required this.png, required this.svg, required this.alt});

  factory Flags.fromJson(Map<String, dynamic> json) => _$FlagsFromJson(json);

  Map<String, dynamic> toJson() => _$FlagsToJson(this);
}
