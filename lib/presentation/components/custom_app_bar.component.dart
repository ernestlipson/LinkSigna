import 'package:flutter/material.dart';

import '../../infrastructure/utils/app_icons.dart';

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
              // Help/Question icon
              IconButton(
                onPressed: onHelpTap,
                icon: AppIcons.messageQuestion(),
              ),
              IconButton(
                  onPressed: onNotificationTap,
                  icon: AppIcons.notification(
                    size: 24,
                  )),
              const SizedBox(width: 8),
              // Profile image
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00C853),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: profileImageUrl != null
                        ? Image.network(
                            profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : _buildDefaultAvatar(),
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
