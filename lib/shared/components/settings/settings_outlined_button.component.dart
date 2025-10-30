import 'package:flutter/material.dart';

/// A reusable outlined button component for settings screens.
class SettingsOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;
  final bool fullWidth;

  const SettingsOutlinedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.color,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: fullWidth ? const Size(double.infinity, 0) : null,
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
