import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/theme/app_theme.dart';

/// A reusable save changes button with loading state for settings screens.
class SaveChangesButton extends StatelessWidget {
  final RxBool isSaving;
  final VoidCallback onSave;
  final String label;
  final bool fullWidth;

  const SaveChangesButton({
    super.key,
    required this.isSaving,
    required this.onSave,
    this.label = 'Save Changes',
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => ElevatedButton(
          onPressed: isSaving.value ? null : onSave,
          style: ElevatedButton.styleFrom(
            minimumSize: fullWidth ? const Size(double.infinity, 0) : null,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: isSaving.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
        ));
  }
}
