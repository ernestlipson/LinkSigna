import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../infrastructure/dal/services/booking.firestore.service.dart';
import '../../../../infrastructure/dal/services/user.firestore.service.dart';
import '../../shared/controllers/student_user.controller.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

class DeafHistoryController extends GetxController {
  final completedBookings = <Map<String, dynamic>>[].obs;
  final _service = Get.find<BookingFirestoreService>();
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  late final String _studentId;

  @override
  void onInit() {
    super.onInit();
    _initializeStudentId();
  }

  Future<void> _initializeStudentId() async {
    _studentId = await _resolveStudentId();
    Get.log('DeafHistoryController: Resolved student ID: $_studentId');

    // Only start listening if we have a valid student ID
    if (!_studentId.startsWith('student_fallback_')) {
      _listen();
    } else {
      Get.log('DeafHistoryController: Using fallback ID, history may not load');
    }
  }

  Future<String> _resolveStudentId() async {
    // First: Try to get from SharedPreferences (most reliable)
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedId = prefs.getString('student_user_doc_id');
      if (cachedId != null && cachedId.isNotEmpty) {
        Get.log(
            'DeafHistoryController: Using cached student ID from SharedPreferences: $cachedId');
        return cachedId;
      }
    } catch (e) {
      Get.log('Error reading from SharedPreferences: $e');
    }

    // Second: Get student ID from StudentUserController if available
    if (Get.isRegistered<StudentUserController>()) {
      final studentController = Get.find<StudentUserController>();
      final currentStudent = studentController.current.value;
      if (currentStudent != null && currentStudent.uid.isNotEmpty) {
        Get.log(
            'DeafHistoryController: Using student ID from controller: ${currentStudent.uid}');
        return currentStudent.uid;
      }
    }

    // Third: Try to find by Firebase Auth UID
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      try {
        final userService = Get.find<UserFirestoreService>();
        final user = await userService.findByAuthUid(authUser.uid);
        if (user != null && user.isStudent) {
          Get.log(
              'DeafHistoryController: Found student by authUid: ${user.uid}');
          // Cache it for next time
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('student_user_doc_id', user.uid);
          return user.uid;
        }
      } catch (e) {
        Get.log('Error finding user by authUid: $e');
      }
    }

    // Fallback: generate a UUID if no proper student ID found
    Get.log('Warning: No proper student ID found, using fallback');
    return 'student_fallback_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _listen() {
    Get.log(
        'DeafHistoryController: Starting to listen for completed bookings for student: $_studentId');
    _sub = _service.bookingsForStudent(_studentId).listen((data) {
      // Filter only completed bookings
      final completed =
          data.where((booking) => booking['status'] == 'completed').toList();

      Get.log(
          'DeafHistoryController: Received ${completed.length} completed bookings');
      completedBookings.assignAll(completed);
    }, onError: (e) {
      Get.log('Completed bookings stream error: $e');
    });
  }

  /// Check if chat is still active (within 24 hours of completion)
  bool isChatActive(Map<String, dynamic> booking) {
    final completedAt = booking['completedAt'] as Timestamp?;
    if (completedAt == null) return false;

    final completedDate = completedAt.toDate();
    final now = DateTime.now();
    final difference = now.difference(completedDate);

    // Chat is active for 24 hours after completion
    return difference.inHours < 24;
  }

  /// Get formatted date string
  String getFormattedDate(Map<String, dynamic> booking) {
    final dateTime =
        (booking['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// Get formatted time string
  String getFormattedTime(Map<String, dynamic> booking) {
    final dateTime =
        (booking['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Message interpreter - Navigate to chat screen
  void messageInterpreter(Map<String, dynamic> booking) {
    if (!isChatActive(booking)) {
      AppSnackbar.warning(
        title: 'Chat Expired',
        message: 'The chat window has expired (24 hours after session)',
      );
      return;
    }

    final bookingId = booking['id'] as String?;
    final interpreterName = booking['interpreterName'] as String? ?? 'Interpreter';

    if (bookingId == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Invalid booking data',
      );
      return;
    }

    // Get current student info
    String currentUserId = _studentId;
    String currentUserName = 'Student';

    if (Get.isRegistered<StudentUserController>()) {
      final studentController = Get.find<StudentUserController>();
      final currentStudent = studentController.current.value;
      if (currentStudent != null) {
        currentUserName = currentStudent.fullName;
      }
    }

    Get.log('Navigating to chat with interpreter: $interpreterName');
    Get.toNamed(
      '/chat',
      arguments: {
        'bookingId': bookingId,
        'currentUserId': currentUserId,
        'currentUserName': currentUserName,
        'currentUserRole': 'student',
        'otherPartyName': interpreterName,
        'otherPartyRole': 'interpreter',
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
