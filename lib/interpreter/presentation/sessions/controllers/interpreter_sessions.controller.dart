import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sign_language_app/shared/call/video_call.screen.dart';
import '../../../../domain/sessions/session.model.dart';
import '../../../../infrastructure/dal/services/session.firestore.service.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';

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
    // Get interpreter ID from InterpreterProfileController if available
    if (Get.isRegistered<InterpreterProfileController>()) {
      final interpreterController = Get.find<InterpreterProfileController>();
      final interpreterId = interpreterController.interpreterId.value;
      if (interpreterId.isNotEmpty) {
        return interpreterId; // This is the Firestore document ID
      }
    }

    // Fallback: generate a UUID if no proper interpreter ID found
    Get.log('Warning: No proper interpreter ID found, using fallback');
    return 'interpreter_fallback_${DateTime.now().millisecondsSinceEpoch}';
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

    try {
      await _service.cancelSession(session.id);
      Get.snackbar(
        'Session Cancelled',
        'Session "${session.className}" has been cancelled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel session: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> confirmSession(SessionModel session) async {
    if (session.status != 'Pending') return;

    try {
      await _service.confirmSession(session.id);
      Get.snackbar(
        'Session Confirmed',
        'Session "${session.className}" has been confirmed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to confirm session: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
