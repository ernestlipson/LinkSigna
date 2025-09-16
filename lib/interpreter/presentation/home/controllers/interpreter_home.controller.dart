import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../domain/models/session.dart';

class InterpreterHomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxList<Session> upcomingSessions = <Session>[].obs;
  final RxList<Session> historySessions = <Session>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void _loadSessions() {
    // Mock data - replace with actual API calls
    upcomingSessions.value = [
      Session(
        id: '1',
        studentName: 'Micheal Chen',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionStatus.confirmed,
      ),
      Session(
        id: '2',
        studentName: 'Micheal Chen',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionStatus.pending,
      ),
    ];

    historySessions.value = [
      Session(
        id: '3',
        studentName: 'Micheal Chen',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionStatus.completed,
        rating: 4,
      ),
    ];
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
