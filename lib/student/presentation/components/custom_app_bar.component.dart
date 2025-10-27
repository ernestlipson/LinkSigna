import 'package:flutter/material.dart';
import 'package:sign_language_app/shared/components/profile_app_bar.component.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? profileImageUrl;
  final String? localImagePath;
  final VoidCallback? onHelpTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool hasNotification;

  const CustomAppBar({
    super.key,
    this.profileImageUrl,
    this.localImagePath,
    this.onHelpTap,
    this.onNotificationTap,
    this.onProfileTap,
    this.hasNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileAppBar(
      profileImageUrl: profileImageUrl,
      localImagePath: localImagePath,
      onHelpTap: onHelpTap,
      onNotificationTap: onNotificationTap,
      onProfileTap: onProfileTap,
      hasNotification: hasNotification,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
