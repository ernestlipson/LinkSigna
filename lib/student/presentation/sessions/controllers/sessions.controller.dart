import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/sessions/session.model.dart';
import '../../../../infrastructure/dal/services/session.firestore.service.dart';
import '../../call/video_call.screen.dart';
import '../../shared/controllers/student_user.controller.dart';

class SessionsController extends GetxController {
  final sessions = <SessionModel>[].obs;
  final searchQuery = ''.obs;
  final _service = Get.find<SessionFirestoreService>();
  StreamSubscription<List<SessionModel>>? _sub;
  late final String _studentId;

  @override
  void onInit() {
    super.onInit();
    _studentId = _resolveStudentId();
    _listen();
  }

  String _resolveStudentId() {
    // Get student ID from StudentUserController if available
    if (Get.isRegistered<StudentUserController>()) {
      final studentController = Get.find<StudentUserController>();
      final currentStudent = studentController.current.value;
      if (currentStudent != null && currentStudent.uid.isNotEmpty) {
        return currentStudent.uid; // This is the Firestore document ID
      }
    }

    // Fallback: generate a UUID if no proper student ID found
    Get.log('Warning: No proper student ID found, using fallback');
    return 'student_fallback_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _listen() {
    _sub = _service.sessionsForStudent(_studentId).listen((data) {
      sessions.assignAll(data);
    }, onError: (e) {
      Get.log('Sessions stream error: $e');
      Get.snackbar('Error', 'Failed to load sessions',
          snackPosition: SnackPosition.BOTTOM);
    });
  }

  List<SessionModel> get filteredSessions {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return sessions;
    return sessions
        .where((s) =>
            s.className.toLowerCase().contains(q) ||
            s.id.toLowerCase().contains(q))
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
      case 'Cancelled':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFFD1FAE5);
      case 'Pending':
        return const Color(0xFFFDE68A);
      case 'Cancelled':
        return const Color(0xFFFECACA);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Future<void> createDummySession() async {
    final start = DateTime.now().add(const Duration(minutes: 30));
    await _service.createSession(
      studentId: _studentId,
      interpreterId: 'interpreter_test_id',
      className: 'Communication Skills',
      startTime: start,
    );
  }

  void joinVideoCall(SessionModel session) {
    if (!isSessionActive(session)) {
      Get.snackbar('Cannot Join', 'Session not active yet',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.to(() => VideoCallScreen(channelId: session.channelId));
  }

  Future<void> cancelSession(SessionModel session) async {
    if (session.status == 'Cancelled') return;
    await _service.updateStatus(session.id, 'Cancelled');
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
