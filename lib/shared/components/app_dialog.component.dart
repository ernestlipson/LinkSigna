import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app.button.dart';

class AppDialog {
  AppDialog._();

  static Future<bool?> showModernConfirmation({
    required String title,
    required String message,
    String confirmLabel = 'Yes',
    String cancelLabel = 'No',
    Color confirmColor = const Color(0xFFE53935),
    Color cancelColor = const Color(0xFF666666),
    bool barrierDismissible = true,
  }) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Get.back(result: false),
                  ),
                ],
              ),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: CustomOutlinedButton(
                        text: cancelLabel,
                        onPressed: () => Get.back(result: false),
                        borderColor: Colors.grey.shade300,
                        textColor: cancelColor,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: cancelColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: CustomButton(
                        text: confirmLabel,
                        onPressed: () => Get.back(result: true),
                        color: confirmColor,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<bool?> showCompactConfirmation({
    required String title,
    required String message,
    String confirmLabel = 'Yes',
    String cancelLabel = 'Cancel',
    Color confirmColor = const Color(0xFFE53935),
    bool barrierDismissible = true,
  }) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Get.back(result: false),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomOutlinedButton(
                      text: cancelLabel,
                      onPressed: () => Get.back(result: false),
                      borderColor: const Color(0xFFE0E0E0),
                      textColor: const Color(0xFF1A1A1A),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: confirmLabel,
                      onPressed: () => Get.back(result: true),
                      color: confirmColor,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<bool?> showLogoutConfirmation({
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) async {
    final result = await showCompactConfirmation(
      title: 'Logout',
      message:
          'Are you sure you want to log out?\nBy logging out, you will be securely logged out of the system and your session will be ended.',
      confirmLabel: 'Yes',
      cancelLabel: 'Cancel',
      confirmColor: const Color(0xFFE53935),
      barrierDismissible: barrierDismissible,
    );

    if (result == true && onConfirm != null) {
      onConfirm();
    } else if (result == false && onCancel != null) {
      onCancel();
    }

    return result;
  }

  static Future<bool?> showCancelSessionConfirmation({
    bool barrierDismissible = true,
  }) {
    return showModernConfirmation(
      title: 'Cancel Session',
      message: 'Are you sure you want to cancel this "Session"?',
      confirmLabel: 'Yes',
      cancelLabel: 'No',
      confirmColor: const Color(0xFFE53935),
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<bool?> showDeleteConfirmation({
    required String itemName,
    String? message,
    bool barrierDismissible = true,
  }) {
    return showModernConfirmation(
      title: 'Delete $itemName',
      message: message ?? 'Are you sure you want to delete this $itemName?',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      confirmColor: const Color(0xFFE53935),
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
