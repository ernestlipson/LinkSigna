import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';

enum AppSnackbarType { success, error, info, warning }

class AppSnackbar {
  AppSnackbar._();

  static void success({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      title: title,
      message: message,
      type: AppSnackbarType.success,
      position: position,
      duration: duration,
    );
  }

  static void error({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      title: title,
      message: message,
      type: AppSnackbarType.error,
      position: position,
      duration: duration,
    );
  }

  static void info({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      title: title,
      message: message,
      type: AppSnackbarType.info,
      position: position,
      duration: duration,
    );
  }

  static void warning({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      title: title,
      message: message,
      type: AppSnackbarType.warning,
      position: position,
      duration: duration,
    );
  }

  static void _show({
    required String title,
    required String message,
    required AppSnackbarType type,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    final _SnackbarPalette palette = _palette(type);

    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: palette.background,
      colorText: palette.foreground,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration,
      icon: Icon(
        palette.icon,
        color: palette.iconColor,
      ),
      shouldIconPulse: false,
      isDismissible: true,
    );
  }

  static _SnackbarPalette _palette(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return _SnackbarPalette(
          background: Colors.green[100]!,
          foreground: Colors.green[900]!,
          iconColor: Colors.green[800]!,
          icon: Icons.check_circle_outline,
        );
      case AppSnackbarType.error:
        return _SnackbarPalette(
          background: Colors.red[100]!,
          foreground: Colors.red[900]!,
          iconColor: Colors.red[800]!,
          icon: Icons.error_outline,
        );
      case AppSnackbarType.warning:
        return _SnackbarPalette(
          background: Colors.orange[100]!,
          foreground: Colors.orange[900]!,
          iconColor: Colors.orange[800]!,
          icon: Icons.warning_amber_rounded,
        );
      case AppSnackbarType.info:
        return _SnackbarPalette(
          background: AppColors.primary.withOpacity(0.1),
          foreground: AppColors.primary,
          iconColor: AppColors.primary,
          icon: Icons.info_outline,
        );
    }
  }
}

class _SnackbarPalette {
  final Color background;
  final Color foreground;
  final Color iconColor;
  final IconData icon;

  const _SnackbarPalette({
    required this.background,
    required this.foreground,
    required this.iconColor,
    required this.icon,
  });
}
