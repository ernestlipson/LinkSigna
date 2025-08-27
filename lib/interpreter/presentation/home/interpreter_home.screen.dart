import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../infrastructure/theme/app_theme.dart';
import '../components/coming.soon.placeholder.dart';
import 'controllers/interpreter_home.controller.dart';

class InterpreterHomeScreen extends StatelessWidget {
  const InterpreterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterpreterHomeController());

    // Define the pages for each tab
    final List<Widget> pages = [
      const ComingSoonPlaceholder(
        title: 'Home Dashboard',
        subtitle: 'Your interpreter dashboard will be available soon.',
      ),
      const ComingSoonPlaceholder(
        title: 'Sessions',
        subtitle: 'Manage your interpretation sessions here.',
      ),
      const ComingSoonPlaceholder(
        title: 'Messages',
        subtitle: 'Chat with your clients and colleagues.',
      ),
      const ComingSoonPlaceholder(
        title: 'History',
        subtitle: 'View your session history and earnings.',
      ),
      const ComingSoonPlaceholder(
        title: 'Settings',
        subtitle: 'Manage your profile and preferences.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Link',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              TextSpan(
                text: 'Signa',
                style: TextStyle(
                  color: Color(0xFF9C0057),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.snackbar('Notifications', 'No new notifications');
            },
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() => pages[controller.selectedIndex.value]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() => BottomNavigationBar(
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              currentIndex: controller.selectedIndex.value,
              onTap: controller.changeTab,
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey[600],
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/home-2.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex.value == 0
                          ? primaryColor
                          : Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/clock.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex.value == 1
                          ? primaryColor
                          : Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Sessions',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/messages-3.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex.value == 2
                          ? primaryColor
                          : Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Message',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/diagram.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex.value == 3
                          ? primaryColor
                          : Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/setting-2.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex.value == 4
                          ? primaryColor
                          : Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: 'Setting',
                ),
              ],
            )),
      ),
    );
  }
}
