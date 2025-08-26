import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF9E1068);
const Color secondaryColor = Color(0xFFFCF8F8);
const Color alternateColor = Color(0xFFD9D9D9);
const textColor = Color(0xFF374151);
const iconColor = Color(0xFF292D32);

final ThemeData appTheme = ThemeData(
  fontFamily: "WorkSans",
  primaryColor: primaryColor,
  hintColor: secondaryColor,
  scaffoldBackgroundColor: secondaryColor,
  textTheme: TextTheme().apply(
    fontFamily: 'WorkSans',
  ),
  appBarTheme: AppBarTheme(
    color: secondaryColor,
    iconTheme: IconThemeData(color: primaryColor),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: primaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: alternateColor,
      )
      .copyWith(surface: secondaryColor),
);
