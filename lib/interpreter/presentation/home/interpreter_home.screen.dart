import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import '../components/custom_app_bar.component.dart';
import '../messages/interpreter_messages.screen.dart';
import '../sessions/interpreter_sessions.screen.dart';
import '../history/interpreter_history.screen.dart';
import '../settings/interpreter_settings.screen.dart';
import 'controllers/interpreter_home.controller.dart';
import 'widgets/interpreter_dashboard.dart';

class InterpreterHomeScreen extends StatelessWidget {
  const InterpreterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterpreterHomeController());

    final List<Widget> pages = [
      const InterpreterDashboard(),
      InterpreterSessionsScreen(),
      const InterpreterMessagesScreen(),
      const InterpreterHistoryScreen(),
      const InterpreterSettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications clicked')),
          );
        },
        onProfileTap: () {
          Get.to(() => const InterpreterSettingsScreen(showBackButton: true));
        },
        hasNotification: false,
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
              selectedItemColor: AppColors.primary,
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
                          ? AppColors.primary
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
                          ? AppColors.primary
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
                          ? AppColors.primary
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
                          ? AppColors.primary
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
                          ? AppColors.primary
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
