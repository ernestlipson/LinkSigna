import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../infrastructure/dal/services/booking.firestore.service.dart';
import '../../../../infrastructure/dal/services/user.firestore.service.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';

class InterpreterHistoryController extends GetxController {
  final completedBookings = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final _service = Get.find<BookingFirestoreService>();
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  Worker? _interpreterIdWorker;
  late final String _interpreterId;

  @override
  void onInit() {
    super.onInit();
    _initializeInterpreterId();
  }

  Future<void> _initializeInterpreterId() async {
    _interpreterId = await _resolveInterpreterId();
    Get.log(
        'InterpreterHistoryController: Resolved interpreter ID: $_interpreterId');

    // Only start listening if we have a valid interpreter ID
    if (!_interpreterId.startsWith('interpreter_fallback_')) {
      _listen();
    } else {
      Get.log(
          'InterpreterHistoryController: Using fallback ID, history may not load');
    }
  }

  Future<String> _resolveInterpreterId() async {
    // First: Try to get from SharedPreferences (most reliable)
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedId = prefs.getString('interpreter_id');
      if (cachedId != null && cachedId.isNotEmpty) {
        Get.log(
            'InterpreterHistoryController: Using cached interpreter ID from SharedPreferences: $cachedId');
        return cachedId;
      }
    } catch (e) {
      Get.log('Error reading from SharedPreferences: $e');
    }

    // Second: Get interpreter ID from InterpreterProfileController if available
    if (Get.isRegistered<InterpreterProfileController>()) {
      final profileController = Get.find<InterpreterProfileController>();
      final currentInterpreterId = profileController.interpreterId.value;
      if (currentInterpreterId.isNotEmpty) {
        Get.log(
            'InterpreterHistoryController: Using interpreter ID from controller: $currentInterpreterId');
        return currentInterpreterId;
      }
    }

    // Third: Try to find by Firebase Auth UID
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      try {
        final userService = Get.find<UserFirestoreService>();
        final user = await userService.findByAuthUid(authUser.uid);
        if (user != null && user.isInterpreter) {
          Get.log(
              'InterpreterHistoryController: Found interpreter by authUid: ${user.uid}');
          // Cache it for next time
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('interpreter_id', user.uid);
          return user.uid;
        }
      } catch (e) {
        Get.log('Error finding user by authUid: $e');
      }
    }

    // Fallback: generate a UUID if no proper interpreter ID found
    Get.log('Warning: No proper interpreter ID found, using fallback');
    return 'interpreter_fallback_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _listen() {
    Get.log(
        'InterpreterHistoryController: Starting to listen for completed bookings for interpreter: $_interpreterId');
    _sub = _service.bookingsForInterpreter(_interpreterId).listen((data) {
      // Filter only completed bookings
      final completed =
          data.where((booking) => booking['status'] == 'completed').toList();

      Get.log(
          'InterpreterHistoryController: Received ${completed.length} completed bookings');
      completedBookings.assignAll(completed);
    }, onError: (e) {
      Get.log('Completed bookings stream error: $e');
    });
  }

  List<Map<String, dynamic>> get filteredHistory {
    if (searchQuery.value.isEmpty) {
      return completedBookings;
    }
    return completedBookings.where((booking) {
      final studentName =
          (booking['studentName'] as String? ?? '').toLowerCase();
      final query = searchQuery.value.toLowerCase();
      return studentName.contains(query);
    }).toList();
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

  /// Get rating display
  String getRatingDisplay(Map<String, dynamic> booking) {
    final rating = booking['rating'] as int?;
    if (rating == null || rating == 0) {
      return 'No rating';
    }
    return '$rating ⭐';
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

  /// Open chat with student
  void openChat(Map<String, dynamic> booking) {
    if (!isChatActive(booking)) {
      Get.snackbar(
        'Chat Expired',
        'The chat window has expired (24 hours after session)',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final bookingId = booking['id'] as String?;
    final studentName = booking['studentName'] as String? ?? 'Student';

    if (bookingId == null) {
      Get.snackbar(
        'Error',
        'Invalid booking data',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Get current interpreter info
    String currentUserId = _interpreterId;
    String currentUserName = 'Interpreter';

    if (Get.isRegistered<InterpreterProfileController>()) {
      final profileController = Get.find<InterpreterProfileController>();
      final interpreterProfile = profileController.profile.value;
      if (interpreterProfile != null) {
        currentUserName = interpreterProfile.fullName;
      }
    }

    Get.log('Navigating to chat with student: $studentName');
    Get.toNamed(
      '/chat',
      arguments: {
        'bookingId': bookingId,
        'currentUserId': currentUserId,
        'currentUserName': currentUserName,
        'currentUserRole': 'interpreter',
        'otherPartyName': studentName,
        'otherPartyRole': 'student',
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    _interpreterIdWorker?.dispose();
    super.onClose();
  }
}
