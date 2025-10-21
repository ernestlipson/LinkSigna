import 'package:flutter/material.dart';

import '../../infrastructure/theme/app_theme.dart';

class UserTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const UserTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio<String>(
          value: 'student',
          groupValue: selectedType,
          onChanged: (String? value) {
            if (value != null) {
              onTypeChanged(value);
            }
          },
          activeColor: AppColors.primary,
        ),
        Text(
          'Student',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                selectedType == 'student' ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 30),
        Radio<String>(
          value: 'interpreter',
          groupValue: selectedType,
          onChanged: (String? value) {
            if (value != null) {
              onTypeChanged(value);
            }
          },
          activeColor: AppColors.primary,
        ),
        Text(
          'Interpreter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: selectedType == 'interpreter'
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
