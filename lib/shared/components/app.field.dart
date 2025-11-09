import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isRequired;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? errorText;
  final String labelText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.labelText,
    this.controller,
    this.isRequired = false,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.errorText,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(labelText: labelText, isRequired: isRequired),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onTap: onTap,
            validator: (value) {
              if (!isRequired) return null;
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            },
            style: const TextStyle(fontFamily: 'WorkSans'),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFFFF),
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'WorkSans',
                color: AppColors.alternate,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              prefixIcon: prefix,
              suffixIcon: suffix,
              errorText: errorText,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFD9D9D9),
                  width: 1,
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
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String labelText;
  final bool isRequired;
  const _Label({required this.labelText, required this.isRequired});

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      color: Colors.black,
      fontFamily: 'WorkSans',
      fontWeight: FontWeight.w500,
    );

    if (!isRequired) {
      return Text(labelText, style: baseStyle);
    }
    return RichText(
      text: TextSpan(
        text: labelText,
        style: baseStyle,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
