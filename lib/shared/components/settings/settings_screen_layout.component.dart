import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';

class SettingsScreenLayout extends StatelessWidget {
  final RxInt selectedTab;
  final Widget Function() buildProfileTab;
  final Widget Function()? buildNotificationsTab;
  final PreferredSizeWidget? appBar;
  final bool useSafeArea;
  final String profileTabLabel;
  final String notificationsTabLabel;

  const SettingsScreenLayout({
    super.key,
    required this.selectedTab,
    required this.buildProfileTab,
    this.buildNotificationsTab,
    this.appBar,
    this.useSafeArea = false,
    this.profileTabLabel = 'Profile',
    this.notificationsTabLabel = 'Notifications',
  });

  @override
  Widget build(BuildContext context) {
    final hasNotifications = buildNotificationsTab != null;

    Widget content = Column(
      children: [
        if (hasNotifications)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: _SettingsTab(
                        title: profileTabLabel,
                        isSelected: selectedTab.value == 0,
                        onTap: () => selectedTab.value = 0,
                      ),
                    ),
                    Expanded(
                      child: _SettingsTab(
                        title: notificationsTabLabel,
                        isSelected: selectedTab.value == 1,
                        onTap: () => selectedTab.value = 1,
                      ),
                    ),
                  ],
                )),
          ),
        Expanded(
          child: hasNotifications
              ? Obx(
                  () => selectedTab.value == 0
                      ? buildProfileTab()
                      : buildNotificationsTab!(),
                )
              : buildProfileTab(),
        ),
      ],
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: content,
    );
  }
}

class _SettingsTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SettingsTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primary : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
