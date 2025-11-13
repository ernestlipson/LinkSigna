import 'package:flutter/material.dart';

class SearchBarComponent extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? hintColor;

  const SearchBarComponent({
    super.key,
    required this.onChanged,
    this.hintText = 'Search',
    this.controller,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? Colors.grey.shade200,
          ),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: hintColor ?? Colors.grey,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: iconColor ?? Colors.grey,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}
