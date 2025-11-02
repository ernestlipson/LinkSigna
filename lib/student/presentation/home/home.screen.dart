import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/student/presentation/deaf-history/deaf_history.screen.dart';
import 'package:sign_language_app/student/presentation/home/home.dashboard.dart';
import 'package:sign_language_app/shared/components/base_home_screen.component.dart';
import 'package:sign_language_app/shared/components/custom_bottom_nav_bar.component.dart';

import 'package:sign_language_app/shared/helpers/navigation_items.helper.dart';
import '../../../shared/components/app_bar.component.dart';
import '../deaf-history/controllers/deaf_history.controller.dart';
import '../interpreters/interpreters.screen.dart';
import '../sessions/controllers/sessions.controller.dart';
import '../sessions/sessions.screen.dart';
import '../settings/controllers/settings.controller.dart';
import '../settings/settings.screen.dart';
import '../shared/controllers/user.controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => <Widget>[
        const HomeDashboard(),
        const StudentBookInterpretersScreen(),
        const SessionsScreen(),
        const DeafHistoryScreen(),
        const SettingsScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications clicked')),
    );
  }

  void _onProfileTap() {
    // Navigate to the settings page (profile tab)
    setState(() {
      _selectedIndex = 4; // Settings is at index 4
    });

    // Also ensure the settings controller opens the profile tab (index 0)
    if (Get.isRegistered<SettingsController>()) {
      final settingsController = Get.find<SettingsController>();
      settingsController.selectedTab.value = 0; // Profile tab
    }
  }

  List<BottomNavItem> get _navigationItems =>
      NavigationItemsHelper.getStudentNavigationItems();

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    // Ensure SessionsController is available
    if (!Get.isRegistered<SessionsController>()) {
      Get.lazyPut<SessionsController>(() => SessionsController());
    }

    // Ensure DeafHistoryController is available
    if (!Get.isRegistered<DeafHistoryController>()) {
      Get.lazyPut<DeafHistoryController>(() => DeafHistoryController());
    }

    // Ensure SettingsController is available
    if (!Get.isRegistered<SettingsController>()) {
      Get.lazyPut<SettingsController>(() => SettingsController());
    }

    return BaseHomeScreen(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => CustomAppBar(
              profileImageUrl: userController.photoUrl.value.isNotEmpty
                  ? userController.photoUrl.value
                  : null,
              localImagePath: userController.localImagePath.value.isNotEmpty
                  ? userController.localImagePath.value
                  : null,
              hasNotification: true,
              onNotificationTap: _onNotificationTap,
              onProfileTap: _onProfileTap,
            )),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      currentIndex: _selectedIndex,
      onNavigationTap: _onItemTapped,
      navigationItems: _navigationItems,
    );
  }
}
