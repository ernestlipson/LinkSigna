import 'package:flutter/material.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import 'package:sign_language_app/presentation/components/custom_app_bar.component.dart';
import 'package:sign_language_app/presentation/home/home.dashboard.dart';

import '../../infrastructure/utils/app_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeDashboard(),
    Center(child: Text('Interpreter', style: TextStyle(fontSize: 20))),
    Center(child: Text('Sessions', style: TextStyle(fontSize: 20))),
    Center(child: Text('History', style: TextStyle(fontSize: 20))),
    Center(child: Text('Setting', style: TextStyle(fontSize: 20))),
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
    // Handle notification tap
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications clicked')),
    );
  }

  void _onProfileTap() {
    // Handle profile tap
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile clicked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        hasNotification: true, // Set to true to show the red notification dot
        onHelpTap: _onHelpTap,
        onNotificationTap: _onNotificationTap,
        onProfileTap: _onProfileTap,
        // You can provide a profile image URL here
        // profileImageUrl: 'https://example.com/profile.jpg',
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.access_time),
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
    );
  }
}
