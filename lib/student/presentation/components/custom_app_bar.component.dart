import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'package:sign_language_app/infrastructure/utils/app_icons.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? profileImageUrl;
  final String? localImagePath; // Add this parameter
  final VoidCallback? onHelpTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool hasNotification;

  const CustomAppBar({
    super.key,
    this.profileImageUrl,
    this.localImagePath, // Add this
    this.onHelpTap,
    this.onNotificationTap,
    this.onProfileTap,
    this.hasNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.grey[300],
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppIcons.travelIB(width: 120),
          // Right side icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: onNotificationTap,
                  icon: Stack(
                    children: [
                      AppIcons.notification(
                        size: 24,
                      ),
                      if (hasNotification)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  )),
              const SizedBox(width: 8),
              // Profile image
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  height: 33,
                  width: 33,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE4E4E4),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: _buildProfileImage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    // Prioritize local image over network image
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      final file = File(localImagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      }
    }

    // Fall back to network image
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profileImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultAvatar(),
      );
    }

    // Default avatar
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
