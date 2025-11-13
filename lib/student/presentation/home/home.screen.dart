import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/base_home_screen.component.dart';
import 'package:sign_language_app/shared/helpers/navigation_items.helper.dart';
import '../../../shared/components/app_bar.component.dart';
import '../../../shared/components/app_dialog.component.dart';
import '../shared/controllers/student_user.controller.dart';
import '../settings/controllers/settings.controller.dart';
import 'controllers/home.controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final studentUserController = Get.find<StudentUserController>();
    final navigationItems = NavigationItemsHelper.getStudentNavigationItems();

    void handleLogout() {
      AppDialog.showLogoutConfirmation(
        onConfirm: () {
          // Get the settings controller which has the logout method
          if (Get.isRegistered<SettingsController>()) {
            Get.find<SettingsController>().logout();
          } else {
            // If not registered, create it temporarily
            final settingsController = Get.put(SettingsController());
            settingsController.logout();
          }
        },
      );
    }

    return Obx(
      () => BaseHomeScreen(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomAppBar(
            profileImageUrl: studentUserController.current.value?.avatarUrl,
            localImagePath:
                studentUserController.localImagePath.value.isNotEmpty
                    ? studentUserController.localImagePath.value
                    : null,
            hasNotification: true,
            onNotificationTap: homeController.showNotifications,
            onProfileTap: homeController.goToProfileTab,
            onLogoutTap: handleLogout,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
                child:
                    homeController.pages[homeController.selectedIndex.value]),
          ],
        ),
        currentIndex: homeController.selectedIndex.value,
        onNavigationTap: homeController.changeTab,
        navigationItems: navigationItems,
      ),
    );
  }
}
