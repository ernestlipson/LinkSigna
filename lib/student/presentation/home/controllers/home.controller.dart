import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

import '../../deaf-history/deaf_history.screen.dart';
import '../../interpreters/interpreters.screen.dart';
import '../../sessions/sessions.screen.dart';
import '../../settings/settings.screen.dart';
import '../home.dashboard.dart';
import '../../deaf-history/controllers/deaf_history.controller.dart';
import '../../sessions/controllers/sessions.controller.dart';
import '../../settings/controllers/settings.controller.dart';

/// Controller responsible for student home navigation and actions.
/// Single source of truth for selected tab + side-effects (profile jump, notifications).
class HomeController extends GetxController {
  /// Reactive selected tab index
  final RxInt selectedIndex = 0.obs;

  /// Ordered list of pages matching bottom navigation items order
  final List<GetxController?> _eagerControllers = [];

  /// Pages list kept simple to avoid rebuilding logic in the widget
  final List<dynamic> pages = const [
    HomeDashboard(),
    StudentBookInterpretersScreen(),
    SessionsScreen(),
    DeafHistoryScreen(),
    SettingsScreen(),
  ];

  /// Change active tab
  void changeTab(int index) => selectedIndex.value = index;

  /// Jump to Settings screen and ensure profile tab opens
void goToProfileTab() {
    selectedIndex.value = 4; // Settings tab index
    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().selectedTab.value = 0; // Profile sub-tab
    }
  }

  /// Show notifications (placeholder)
  void showNotifications() {
    AppSnackbar.info(title: 'Notifications', message: 'Clicked');
  }

  @override
  void onInit() {
    super.onInit();
    _ensureControllers();
  }

  void _ensureControllers() {
    if (!Get.isRegistered<SessionsController>()) {
      Get.lazyPut<SessionsController>(() => SessionsController(), fenix: true);
    }
    if (!Get.isRegistered<DeafHistoryController>()) {
      Get.lazyPut<DeafHistoryController>(() => DeafHistoryController(),
          fenix: true);
    }
    if (!Get.isRegistered<SettingsController>()) {
      Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    }
  }
}
