import 'package:flutter/material.dart';
import 'package:sign_language_app/shared/components/custom_bottom_nav_bar.component.dart';

class BaseHomeScreen extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget body;
  final int currentIndex;
  final Function(int) onNavigationTap;
  final List<BottomNavItem> navigationItems;

  const BaseHomeScreen({
    super.key,
    required this.appBar,
    required this.body,
    required this.currentIndex,
    required this.onNavigationTap,
    required this.navigationItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: body,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: onNavigationTap,
        items: navigationItems,
      ),
    );
  }
}
