import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../domain/sessions/session.model.dart';
import '../../../../infrastructure/dal/services/session.firestore.service.dart';
import '../../../../presentation/call/video_call.screen.dart';

class InterpreterSessionsController extends GetxController {
  final sessions = <SessionModel>[].obs;
  final searchQuery = ''.obs;
  final _service = Get.find<SessionFirestoreService>();
  StreamSubscription<List<SessionModel>>? _sub;
  late final String _interpreterId;

  @override
  void onInit() {
    super.onInit();
    _interpreterId = _resolveInterpreterId();
    _listen();
  }

  String _resolveInterpreterId() {
    // TODO: replace with real interpreter auth UID
    return 'interpreter_test_id';
  }

  void _listen() {
    _sub = _service.sessionsForInterpreter(_interpreterId).listen((list) {
      sessions.assignAll(list);
    });
  }

  List<SessionModel> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return sessions;
    return sessions
        .where((s) =>
            s.className.toLowerCase().contains(q) ||
            s.studentId.toLowerCase().contains(q))
        .toList();
  }

  bool isSessionActive(SessionModel s) =>
      s.status == 'Confirmed' &&
      s.startTime.isBefore(DateTime.now().add(const Duration(minutes: 10)));

  Color getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF059669);
      case 'Pending':
        return const Color(0xFF92400E);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color getStatusBg(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFFD1FAE5);
      case 'Pending':
        return const Color(0xFFFDE68A);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  void joinVideoCall(SessionModel session) {
    if (!isSessionActive(session)) {
      Get.snackbar('Not Ready', 'Session not active yet',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.to(() => VideoCallScreen(channelId: session.channelId));
  }

  Future<void> cancelSession(SessionModel session) async {
    if (session.status == 'Cancelled') return;
    await _service.updateStatus(session.id, 'Cancelled');
  }

  Future<void> confirmSession(SessionModel session) async {
    if (session.status == 'Pending') {
      await _service.updateStatus(session.id, 'Confirmed');
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
