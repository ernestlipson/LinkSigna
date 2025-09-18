import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../infrastructure/navigation/routes.dart';
import '../../../domain/models/session.dart';
import '../../../../infrastructure/dal/services/session.firestore.service.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';
import '../../../../domain/sessions/session.model.dart';
import 'dart:async';

class InterpreterHomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxList<Session> upcomingSessions = <Session>[].obs;
  final RxList<Session> historySessions = <Session>[].obs;
  StreamSubscription<List<SessionModel>>? _sub;
  late final SessionFirestoreService _sessionService;
  late final String _interpreterId;

  @override
  void onInit() {
    super.onInit();
    _sessionService = Get.find<SessionFirestoreService>();
    _interpreterId = _resolveInterpreterId();
    _listenToSessions();
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  String _resolveInterpreterId() {
    if (Get.isRegistered<InterpreterProfileController>()) {
      final profileController = Get.find<InterpreterProfileController>();
      final id = profileController.interpreterId.value;
      if (id.isNotEmpty) return id;
    }
    Get.log('Warning: No proper interpreter ID found, using fallback');
    return 'interpreter_fallback_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _listenToSessions() {
    _sub?.cancel();
    _sub =
        _sessionService.sessionsForInterpreter(_interpreterId).listen((list) {
      final now = DateTime.now();
      final upcoming = <Session>[];
      final history = <Session>[];
      for (final s in list) {
        // Only show sessions in the future as upcoming, and not cancelled
        if ((s.status == 'Confirmed' || s.status == 'Pending') &&
            s.startTime.isAfter(now)) {
          upcoming.add(_toDashboardSession(s));
        } else if (s.status == 'Cancelled' ||
            s.status == 'Completed' ||
            s.startTime.isBefore(now)) {
          history.add(_toDashboardSession(s));
        }
      }
      upcomingSessions
          .assignAll(upcoming..sort((a, b) => a.date.compareTo(b.date)));
      historySessions
          .assignAll(history..sort((a, b) => b.date.compareTo(a.date)));
    });
  }

  Session _toDashboardSession(SessionModel s) {
    // You may want to fetch student name from another service if needed
    return Session(
      id: s.id,
      studentName: s.studentId, // Replace with actual student name if available
      className: s.className,
      date: s.startTime,
      time: _formatTime(s.startTime),
      status: _toSessionStatus(s.status),
      rating: null,
      feedback: null,
    );
  }

  SessionStatus _toSessionStatus(String status) {
    switch (status) {
      case 'Confirmed':
        return SessionStatus.confirmed;
      case 'Pending':
        return SessionStatus.pending;
      case 'Cancelled':
        return SessionStatus.cancelled;
      case 'Completed':
        return SessionStatus.completed;
      default:
        return SessionStatus.pending;
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
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
