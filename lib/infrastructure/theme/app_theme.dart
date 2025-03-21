import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF9E1068);
const Color secondaryColor = Color(0xFFFCF8F8);
const Color alternateColor = Color(0xFFD9D9D9);

final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  hintColor: secondaryColor,
  scaffoldBackgroundColor: secondaryColor,
  textTheme: GoogleFonts.workSansTextTheme(),
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
