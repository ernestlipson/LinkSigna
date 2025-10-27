import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/profile_app_bar.component.dart';

import '../shared/controllers/interpreter_profile.controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? profileImageUrl;
  final VoidCallback? onHelpTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool hasNotification;

  const CustomAppBar({
    super.key,
    this.profileImageUrl,
    this.onHelpTap,
    this.onNotificationTap,
    this.onProfileTap,
    this.hasNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<InterpreterProfileController>();

    return ProfileAppBar(
      profileImageUrl: profileImageUrl,
      onHelpTap: onHelpTap,
      onNotificationTap: onNotificationTap,
      onProfileTap: onProfileTap,
      hasNotification: hasNotification,
      profileAvatar: Obx(() {
        final currentProfileImageUrl =
            profileController.profile.value?.profilePictureUrl;

        if (currentProfileImageUrl != null &&
            currentProfileImageUrl.isNotEmpty) {
          return CachedNetworkImage(
            imageUrl: currentProfileImageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => ProfileAppBar.defaultAvatar(),
            errorWidget: (context, url, error) => ProfileAppBar.defaultAvatar(),
          );
        }

        return ProfileAppBar.defaultAvatar();
      }),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
