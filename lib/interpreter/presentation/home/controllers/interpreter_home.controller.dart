import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';

class InterpreterHomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear interpreter login status
      await prefs.setBool('interpreter_logged_in', false);
      await prefs.remove('userName');
      await prefs.remove('userEmail');

      Get.snackbar(
        'Logout',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate back to signup screen
      Get.offAllNamed(Routes.initialRoute);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
