import 'package:flutter/material.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';

class CustomTextFormField extends StatelessWidget {
  /// Hint text to display when the field is empty.
  final String hintText;

  /// Controller for managing the text inside the field.
  final TextEditingController? controller;

  /// Whether this field is required. If true, displays a validation error when empty.
  final bool isRequired;

  /// Whether to obscure the text (e.g., for passwords).
  final bool obscureText;

  /// Optional prefix widget (e.g., a flag icon).
  final Widget? prefix;

  /// Optional suffix widget (e.g., an eye icon for toggling password visibility).
  final Widget? suffix;

  /// Keyboard type (text, phone, email, etc.).
  final TextInputType? keyboardType;
  final String? errorText; // New: to display validation errors
  final String labelText; // New: label text for the field

  const CustomTextFormField(
      {super.key,
      required this.hintText,
      required this.labelText, // New: label text for the field
      this.controller,
      this.isRequired = false,
      this.obscureText = false,
      this.prefix,
      this.suffix,
      this.keyboardType,
      this.errorText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 379,
      height: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: labelText,
              style: TextStyle(
                color: Colors.black,
                fontFamily: "WorkSans",
                fontWeight: FontWeight.w500,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: primaryColor),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            // Basic validator to ensure field is filled if required.
            validator: (value) {
              if (isRequired && (value == null || value.trim().isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
            style: TextStyle(fontFamily: 'WorkSans'),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFFFF), // #FFFFFF
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: "WorkSans",
                color: alternateColor,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              prefixIcon: prefix,
              suffixIcon: suffix,
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), // borderRadiusLG
                borderSide: const BorderSide(
                  color: Color(0xFFD9D9D9), // #D9D9D9
                  width: 1, // lineWidth
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFD9D9D9),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFD9D9D9),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
