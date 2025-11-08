import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/utils/app_icons.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? profileImageUrl;
  final String? localImagePath;
  final Widget? profileAvatar;
  final VoidCallback? onHelpTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;
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
          _buildLogo(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AppIcons.travelIB(width: 120);
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onHelpTap != null) ...[
          _buildHelpButton(),
          const SizedBox(width: 8),
        ],
        _buildProfileMenu(),
      ],
    );
  }

  Widget _buildHelpButton() {
    return IconButton(
      onPressed: onHelpTap,
      icon: const Icon(Icons.help_outline, color: Colors.black87),
    );
  }

  Widget _buildProfileMenu() {
    return _ProfileMenu(
      buildAvatar: _buildProfileImage,
      onProfileTap: onProfileTap,
      onLogoutTap: onLogoutTap,
    );
  }

  Widget _buildProfileImage() {
    if (profileAvatar != null) {
      return profileAvatar!;
    }

    if (_hasLocalImage()) {
      return _buildLocalImage();
    }

    if (_hasNetworkImage()) {
      return _buildNetworkImage();
    }

    return _buildDefaultAvatar();
  }

  bool _hasLocalImage() {
    return localImagePath != null && localImagePath!.isNotEmpty;
  }

  bool _hasNetworkImage() {
    return profileImageUrl != null && profileImageUrl!.isNotEmpty;
  }

  Widget _buildLocalImage() {
    final file = File(localImagePath!);
    if (!file.existsSync()) {
      return _buildDefaultAvatar();
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
    );
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: profileImageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) => _buildDefaultAvatar(),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
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
      color: Colors.white,
      onSelected: _handleMenuSelection,
      elevation: 6,
      offset: const Offset(0, 40),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) => [
        _buildProfileMenuItem(),
        _buildLogoutMenuItem(),
      ],
      child: _buildAvatarContainer(),
    );
  }

  void _handleMenuSelection(_ProfileMenuAction action) {
    switch (action) {
      case _ProfileMenuAction.profile:
        onProfileTap?.call();
        break;
      case _ProfileMenuAction.logout:
        onLogoutTap?.call();
        break;
    }
  }

  PopupMenuItem<_ProfileMenuAction> _buildProfileMenuItem() {
    return PopupMenuItem<_ProfileMenuAction>(
      value: _ProfileMenuAction.profile,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/user-square.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          const Text('Your Profile'),
        ],
      ),
    );
  }

  PopupMenuItem<_ProfileMenuAction> _buildLogoutMenuItem() {
    return PopupMenuItem<_ProfileMenuAction>(
      value: _ProfileMenuAction.logout,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/logout.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          const Text('Log out'),
        ],
      ),
    );
  }

  Widget _buildAvatarContainer() {
    return Container(
      height: 33,
      width: 33,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: ClipOval(child: buildAvatar()),
    );
  }
}
