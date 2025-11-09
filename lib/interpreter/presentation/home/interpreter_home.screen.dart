import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sign_language_app/shared/helpers/navigation_items.helper.dart';
import 'package:sign_language_app/shared/components/base_home_screen.component.dart';
import '../../../shared/components/app_bar.component.dart';
import '../../../shared/components/app_dialog.component.dart';
import '../messages/interpreter_messages.screen.dart';
import '../sessions/interpreter_sessions.screen.dart';
import '../history/interpreter_history.screen.dart';
import '../settings/interpreter_settings.screen.dart';
import 'controllers/interpreter_home.controller.dart';
import 'widgets/interpreter_dashboard.dart';
import '../shared/controllers/interpreter_profile.controller.dart';
import '../settings/controllers/interpreter_settings.controller.dart';

class InterpreterHomeScreen extends StatelessWidget {
  const InterpreterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterpreterHomeController());
    final profileController = Get.find<InterpreterProfileController>();

    final List<Widget> pages = [
      const InterpreterDashboard(),
      InterpreterSessionsScreen(),
      const InterpreterMessagesScreen(),
      const InterpreterHistoryScreen(),
      const InterpreterSettingsScreen(),
    ];

    final navigationItems =
        NavigationItemsHelper.getInterpreterNavigationItems();

    void handleLogout() {
      AppDialog.showLogoutConfirmation(
        onConfirm: () {
          if (Get.isRegistered<InterpreterSettingsController>()) {
            Get.find<InterpreterSettingsController>().logout();
          } else {
            final settingsController =
                Get.put(InterpreterSettingsController());
            settingsController.logout();
          }
        },
      );
    }

    return Obx(
      () => BaseHomeScreen(
        appBar: CustomAppBar(
          profileImageUrl: profileController.profile.value?.avatarUrl,
          localImagePath: profileController.localImagePath.value.isNotEmpty
              ? profileController.localImagePath.value
              : null,
          onNotificationTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications clicked')),
            );
          },
          onProfileTap: () => controller.goToProfileTab(),
          hasNotification: false,
          onLogoutTap: handleLogout,
        ),
        body: pages[controller.selectedIndex.value],
        currentIndex: controller.selectedIndex.value,
        onNavigationTap: controller.changeTab,
        navigationItems: navigationItems,
      ),
    );
  }
}
