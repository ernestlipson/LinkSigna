import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import 'package:sign_language_app/presentation/components/custom_app_bar.component.dart';
import 'package:sign_language_app/presentation/deaf-history/deaf_history.screen.dart';
import 'package:sign_language_app/presentation/home/home.dashboard.dart';

import '../../infrastructure/utils/app_icons.dart';
import '../deaf-history/controllers/deaf_history.controller.dart';
import '../interpreter/controllers/interpreter.controller.dart';
import '../interpreter/interpreter.screen.dart';
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
        const InterpreterScreen(),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile clicked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    // Ensure SessionsController is available
    if (!Get.isRegistered<SessionsController>()) {
      Get.lazyPut<SessionsController>(() => SessionsController());
    }

    // Ensure InterpreterController is available
    if (!Get.isRegistered<InterpreterController>()) {
      Get.lazyPut<InterpreterController>(() => InterpreterController());
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
      appBar: CustomAppBar(
        profileImageUrl: userController.photoUrl.value.isNotEmpty
            ? userController.photoUrl.value
            : "https://image.lexica.art/full_webp/9c76b727-5409-4d42-be53-9b3e41e5f2db",
        hasNotification: true, // Set to true to show the red notification dot
        onHelpTap: _onHelpTap,
        onNotificationTap: _onNotificationTap,
        onProfileTap: _onProfileTap,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Welcome ${userController.displayName.value.isNotEmpty ? userController.displayName.value : "User"}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
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
              icon: AppIcons.calendar(size: 24),
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
