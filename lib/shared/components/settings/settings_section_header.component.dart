import 'package:flutter/material.dart';

/// A reusable section header component for settings screens.
class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: Colors.black,
      ),
    );
  }
}
