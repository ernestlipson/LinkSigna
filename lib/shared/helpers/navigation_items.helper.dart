import 'package:flutter/material.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import 'package:sign_language_app/infrastructure/utils/app_icons.dart';
import 'package:sign_language_app/infrastructure/utils/app_strings.dart';
import 'package:sign_language_app/shared/components/custom_bottom_nav_bar.component.dart';

class NavigationItemsHelper {
  static BottomNavItem _createNavItem({
    required Widget Function({double? size, Color? color}) icon,
    required String label,
  }) {
    return BottomNavItem(
      icon: icon(size: 24, color: Colors.grey[600]),
      activeIcon: icon(size: 24, color: AppColors.primary),
      label: label,
    );
  }

  static List<BottomNavItem> getStudentNavigationItems() {
    return [
      _createNavItem(icon: AppIcons.home, label: AppStrings.navHome),
      _createNavItem(icon: AppIcons.calendar, label: AppStrings.navInterpreter),
      _createNavItem(icon: AppIcons.clock, label: AppStrings.navSessions),
      _createNavItem(icon: AppIcons.diagram, label: AppStrings.navHistory),
      _createNavItem(icon: AppIcons.setting, label: AppStrings.navSetting),
    ];
  }

  static List<BottomNavItem> getInterpreterNavigationItems() {
    return [
      _createNavItem(icon: AppIcons.home, label: AppStrings.navHome),
      _createNavItem(icon: AppIcons.clock, label: AppStrings.navSessions),
      _createNavItem(icon: AppIcons.messages, label: AppStrings.navMessage),
      _createNavItem(icon: AppIcons.diagram, label: AppStrings.navHistory),
      _createNavItem(icon: AppIcons.setting, label: AppStrings.navSetting),
    ];
  }
}
