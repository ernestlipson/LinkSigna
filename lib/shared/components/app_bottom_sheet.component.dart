import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>({
    String? title,
    bool showHandle = true,
    bool showCloseButton = true,
    bool isScrollControlled = true,
    bool isDismissible = true,
    EdgeInsetsGeometry? bodyPadding,
    VoidCallback? onClose,
    required List<Widget> body,
  }) {
    return Get.bottomSheet<T>(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle)
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              if (title != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (showCloseButton)
                        IconButton(
                          onPressed: () {
                            Get.back();
                            onClose?.call();
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              if (body.isNotEmpty)
                Padding(
                  padding:
                      bodyPadding ?? const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: body,
                  ),
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
    );
  }

  static Future<T?> showList<T>({
    required String title,
    required List<Widget> items,
    double? maxHeight,
    EdgeInsetsGeometry? listPadding,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool showHandle = true,
    bool showCloseButton = true,
    VoidCallback? onClose,
  }) {
    return show<T>(
      title: title,
      showHandle: showHandle,
      showCloseButton: showCloseButton,
      body: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight ?? 320,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: listPadding ?? EdgeInsets.zero,
            children: items,
          ),
        ),
      ],
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      onClose: onClose,
    );
  }
}
