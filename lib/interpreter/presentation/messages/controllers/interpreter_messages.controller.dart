import 'package:get/get.dart';

import '../../../../infrastructure/navigation/routes.dart';

enum SessionStatus { active, expired }

class SessionMessage {
  final String id;
  final String title;
  final String className;
  final String date;
  final String time;
  final SessionStatus status;

  SessionMessage({
    required this.id,
    required this.title,
    required this.className,
    required this.date,
    required this.time,
    required this.status,
  });
}

class InterpreterMessagesController extends GetxController {
  final RxList<SessionMessage> sessions = <SessionMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  void loadSessions() {
    // Mock data matching the design from the image
    sessions.value = [
      SessionMessage(
        id: '1',
        title: 'Session with Micheal Chen',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: SessionStatus.active,
      ),
      SessionMessage(
        id: '2',
        title: 'Session with Micheal Chen',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: SessionStatus.active,
      ),
      SessionMessage(
        id: '3',
        title: 'Session with Micheal Chen',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: SessionStatus.active,
      ),
      SessionMessage(
        id: '4',
        title: 'Session with Micheal Chen',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: SessionStatus.expired,
      ),
      SessionMessage(
        id: '5',
        title: 'Session with Micheal Chen',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: SessionStatus.expired,
      ),
      SessionMessage(
        id: '6',
        title: 'Session with Micheal Chen',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: SessionStatus.expired,
      ),
    ];
  }

  void openChat(SessionMessage session) {
    if (session.status == SessionStatus.active) {
      Get.toNamed(Routes.INTERPRETER_CHAT, arguments: {
        'sessionId': session.id,
        'studentName': 'Arlene McCoy', // Extract from session title if needed
        'studentAvatar':
            'https://images.unsplash.com/photo-1494790108755-2616b612b47c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      });
    }
  }

  void refreshSessions() {
    loadSessions();
  }
}
