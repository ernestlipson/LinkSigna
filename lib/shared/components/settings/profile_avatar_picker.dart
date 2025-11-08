import 'package:flutter/material.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';

/// A reusable avatar picker used in settings screens.
class ProfileAvatarPicker extends StatelessWidget {
  final Widget avatarWidget;
  final VoidCallback onTap;
  final bool isUploading;

  const ProfileAvatarPicker({
    super.key,
    required this.avatarWidget,
    required this.onTap,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Avatar supplied by the caller (can be reactive)
          avatarWidget,

          // Camera icon overlay
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),

          // Upload progress indicator
          if (isUploading)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
