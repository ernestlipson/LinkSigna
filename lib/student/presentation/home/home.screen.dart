import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/student/infrastructure/theme/app_theme.dart';
import 'package:sign_language_app/student/presentation/components/custom_app_bar.component.dart';
import 'package:sign_language_app/student/presentation/deaf-history/deaf_history.screen.dart';
import 'package:sign_language_app/student/presentation/home/home.dashboard.dart';

import '../../infrastructure/utils/app_icons.dart';
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
        const InterpretersScreen(),
        const SessionsScreen(),
        const DeafHistoryScreen(),
        const SettingsScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onHelpTap() {
    // Handle help button tap
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Text('How can we help you?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => CustomAppBar(
              profileImageUrl: userController.photoUrl.value.isNotEmpty
                  ? userController.photoUrl.value
                  : null, // Use null to show default avatar
              hasNotification:
                  true, // Set to true to show the red notification dot
              onHelpTap: _onHelpTap,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 1,
            offset: const Offset(0, 3),
          ),
        ]),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey[700],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: AppIcons.home(size: 24, color: Colors.grey[700]),
              activeIcon: AppIcons.home(size: 24, color: primaryColor),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: AppIcons.calendar(size: 24, color: Colors.grey[700]),
              activeIcon: AppIcons.calendar(size: 24, color: primaryColor),
              label: 'Interpreter',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time, color: Colors.grey[700]),
              activeIcon: Icon(Icons.access_time, color: primaryColor),
              label: 'Sessions',
            ),
            BottomNavigationBarItem(
              icon: AppIcons.diagram(size: 24),
              activeIcon: AppIcons.diagram(size: 24, color: primaryColor),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: AppIcons.setting(size: 24),
              activeIcon: AppIcons.setting(size: 24, color: primaryColor),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}
