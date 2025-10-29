import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/app_bottom_sheet.component.dart';

class SettingsBottomSheets {
  /// Show university level selection bottom sheet
  static void showUniversityLevelPicker({
    required List<int> levels,
    required String currentLevel,
    required Function(int) onSelect,
  }) {
    AppBottomSheet.showList(
      title: 'Select University Level',
      maxHeight: 360,
      items: levels.map((level) {
        final isSelected = currentLevel.contains('Level $level');
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          title: Text(
            'Level $level',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            _getLevelDescription(level),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          trailing:
              isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          onTap: () {
            onSelect(level);
            Get.back();
          },
        );
      }).toList(),
    );
  }

  static String _getLevelDescription(int level) {
    switch (level) {
      case 100:
        return 'First Year - Foundation courses';
      case 200:
        return 'Second Year - Core courses';
      case 300:
        return 'Third Year - Advanced courses';
      case 400:
        return 'Fourth Year - Specialization';
      case 500:
        return 'Final Year - Research & Thesis';
      default:
        return '';
    }
  }

  /// Show experience level selection bottom sheet
  static void showExperienceLevelPicker({
    required List<String> levels,
    required String currentLevel,
    required Function(String) onSelect,
  }) {
    AppBottomSheet.showList(
      title: 'Select Experience Level',
      items: levels.map((level) {
        final isSelected = currentLevel == level;
        return ListTile(
          title: Text(level),
          trailing:
              isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          onTap: () {
            onSelect(level);
            Get.back();
          },
        );
      }).toList(),
    );
  }

  /// Show certification selection bottom sheet
  static void showCertificationPicker({
    required List<String> certifications,
    required String currentCertification,
    required Function(String) onSelect,
  }) {
    AppBottomSheet.showList(
      title: 'Select Certification',
      items: certifications.map((cert) {
        final isSelected = currentCertification == cert;
        return ListTile(
          title: Text(cert),
          trailing:
              isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          onTap: () {
            onSelect(cert);
            Get.back();
          },
        );
      }).toList(),
    );
  }

  /// Show simple selection bottom sheet (generic)
  static void showSimpleSelectionPicker({
    required String title,
    required List<String> items,
    required String currentSelection,
    required Function(String) onSelect,
    double? maxHeight,
  }) {
    AppBottomSheet.showList(
      title: title,
      maxHeight: maxHeight,
      items: items.map((item) {
        final isSelected = currentSelection == item;
        return ListTile(
          title: Text(item),
          trailing:
              isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          onTap: () {
            onSelect(item);
            Get.back();
          },
        );
      }).toList(),
    );
  }
}
