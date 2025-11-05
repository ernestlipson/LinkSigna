import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/utils/app_icons.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? profileImageUrl;
  final String? localImagePath;
  final Widget? profileAvatar;
  final VoidCallback? onHelpTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap; // new logout callback
  final bool hasNotification;
  final GetxController? profileController;
  final String? profileImageField;

  const CustomAppBar({
    super.key,
    this.profileImageUrl,
    this.localImagePath,
    this.profileAvatar,
    this.onHelpTap,
    this.onNotificationTap,
    this.onProfileTap,
    this.onLogoutTap,
    this.hasNotification = false,
    this.profileController,
    this.profileImageField,
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onHelpTap != null) ...[
                IconButton(
                  onPressed: onHelpTap,
                  icon: const Icon(Icons.help_outline, color: Colors.black87),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                onPressed: onNotificationTap,
                icon: Stack(
                  children: [
                    AppIcons.notification(size: 24),
                    if (hasNotification)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ProfileMenu(
                buildAvatar: _buildProfileImage,
                onProfileTap: onProfileTap,
                onLogoutTap: onLogoutTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    // If a custom profile avatar widget is provided, use it
    if (profileAvatar != null) {
      return profileAvatar!;
    }

    // Check for local image path first (recently picked image)
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      final file = File(localImagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => defaultAvatar(),
        );
      }
    }

    // Check for network image URL
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profileImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
        errorWidget: (context, url, error) => defaultAvatar(),
      );
    }

    // Default avatar
    return defaultAvatar();
  }

  static Widget defaultAvatar() {
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

enum _ProfileMenuAction { profile, logout }

class _ProfileMenu extends StatelessWidget {
  final Widget Function() buildAvatar;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;

  const _ProfileMenu({
    required this.buildAvatar,
    this.onProfileTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ProfileMenuAction>(
      tooltip: 'Profile menu',
      onSelected: (value) {
        switch (value) {
          case _ProfileMenuAction.profile:
            if (onProfileTap != null) onProfileTap!();
            break;
          case _ProfileMenuAction.logout:
            if (onLogoutTap != null) onLogoutTap!();
            break;
        }
      },
      elevation: 6,
      offset:
          const Offset(0, 40), // shifted: show directly under & aligned right
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<_ProfileMenuAction>(
          value: _ProfileMenuAction.profile,
          child: Row(
            children: const [
              Icon(Icons.person_outline, size: 20, color: Colors.black87),
              SizedBox(width: 8),
              Text('Your Profile'),
            ],
          ),
        ),
        PopupMenuItem<_ProfileMenuAction>(
          value: _ProfileMenuAction.logout,
          child: Row(
            children: const [
              Icon(Icons.logout, size: 20, color: Colors.black87),
              SizedBox(width: 8),
              Text('Log out'),
            ],
          ),
        ),
      ],
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
        child: ClipOval(child: buildAvatar()),
      ),
    );
  }
}
