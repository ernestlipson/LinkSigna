import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDialog {
  AppDialog._();

  static Future<T?> showConfirmation<T>({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    bool barrierDismissible = true,
  }) {
    return Get.dialog<T>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              onCancel?.call();
            },
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: confirmColor,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<T?> showCustom<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return Get.dialog<T>(
      child,
      barrierDismissible: barrierDismissible,
    );
  }
}
