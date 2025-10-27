import 'package:get/get.dart';
import '../deaf_history.screen.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

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
    AppSnackbar.info(
      title: 'Pending Feature',
      message: 'This Feature is Coming Soon',
    );
  }
}
