import 'package:get/get.dart';
import '../deaf_history.screen.dart';

class DeafHistoryController extends GetxController {
  final RxList<SessionData> sessions = <SessionData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
  }

  void _loadSessions() {
    // Mock data for sessions
    sessions.value = [
      SessionData(
        interpreterName: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        isChatActive: true,
      ),
      SessionData(
        interpreterName: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        isChatActive: true,
      ),
      SessionData(
        interpreterName: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        isChatActive: true,
      ),
      SessionData(
        interpreterName: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        isChatActive: false,
      ),
      SessionData(
        interpreterName: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        isChatActive: false,
      ),
      SessionData(
        interpreterName: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        isChatActive: false,
      ),
    ];
  }

  void messageInterpreter(SessionData session) {
    Get.snackbar(
      'Pending Feature',
      'This Feature is Coming Soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
