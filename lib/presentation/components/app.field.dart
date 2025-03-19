import 'package:flutter/material.dart';

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

  const CustomTextFormField(
      {super.key,
      required this.hintText,
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
      height: 40,
      child: TextFormField(
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
        decoration: InputDecoration(
          // The outer container’s background color.
          filled: true,
          fillColor: const Color(0xFFFFFFFF), // #FFFFFF
          hintText: hintText,
          // Horizontal padding set to "paddingInlineLG" equivalent.
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          prefixIcon: prefix,
          suffixIcon: suffix,
          errorText: errorText,
          // The border color, width, and radius.
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
    );
  }
}
