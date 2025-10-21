import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../infrastructure/utils/app_icons.dart';
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
                    child: Obx(() {
                      // Get profile image from InterpreterProfileController
                      final profileController =
                          Get.find<InterpreterProfileController>();
                      final currentProfileImageUrl =
                          profileController.profile.value?.profilePictureUrl;

                      if (currentProfileImageUrl != null &&
                          currentProfileImageUrl.isNotEmpty) {
                        return CachedNetworkImage(
                          imageUrl: currentProfileImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildDefaultAvatar(),
                          errorWidget: (context, url, error) =>
                              _buildDefaultAvatar(),
                        );
                      } else {
                        return _buildDefaultAvatar();
                      }
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
