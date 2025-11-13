import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../infrastructure/dal/services/booking.firestore.service.dart';
import '../../../../infrastructure/dal/services/user.firestore.service.dart';
import 'package:sign_language_app/shared/call/webrtc_call.screen.dart';
import '../../shared/controllers/student_user.controller.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

class SessionsController extends GetxController {
  final bookings = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final _service = Get.find<BookingFirestoreService>();
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  late final String _studentId;

  @override
  void onInit() {
    super.onInit();
    _initializeStudentId();

    // DEBUG: Print all bookings to understand the data
    _service.debugPrintAllBookings();
  }

  Future<void> _initializeStudentId() async {
    _studentId = await _resolveStudentId();
    Get.log('SessionsController: Resolved student ID: $_studentId');

    // Only start listening if we have a valid student ID
    if (!_studentId.startsWith('student_fallback_')) {
      _listen();
    } else {
      Get.log('SessionsController: Using fallback ID, sessions may not load');
    }
  }

  Future<String> _resolveStudentId() async {
    // First: Try to get from SharedPreferences (most reliable)
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedId = prefs.getString('student_user_doc_id');
      if (cachedId != null && cachedId.isNotEmpty) {
        Get.log(
            'SessionsController: Using cached student ID from SharedPreferences: $cachedId');
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
            'SessionsController: Using student ID from controller: ${currentStudent.uid}');
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
          Get.log('SessionsController: Found student by authUid: ${user.uid}');
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
        'SessionsController: Starting to listen for bookings for student: $_studentId');
    _sub = _service.bookingsForStudent(_studentId).listen((data) {
      Get.log('SessionsController: Received ${data.length} bookings');
      for (var booking in data) {
        Get.log(
            'Booking: ${booking['id']} - Status: ${booking['status']} - Student: ${booking['studentId']}');
      }
      bookings.assignAll(data);
    }, onError: (e) {
      Get.log('Bookings stream error: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to load bookings',
      );
    });
  }

  List<Map<String, dynamic>> get filteredSessions {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return bookings;
    return bookings
        .where((b) =>
            (b['interpreterName'] as String? ?? '').toLowerCase().contains(q) ||
            (b['interpreterId'] as String? ?? '').toLowerCase().contains(q) ||
            (b['id'] as String? ?? '').toLowerCase().contains(q))
        .toList();
  }

  // Get only confirmed bookings (ready to join)
  List<Map<String, dynamic>> get confirmedSessions {
    return bookings.where((b) => b['status'] == 'confirmed').toList();
  }

  // Get upcoming sessions (confirmed sessions in the future)
  List<Map<String, dynamic>> get upcomingSessions {
    return bookings.where((b) {
      final status = b['status'] as String?;
      final dateTime = (b['dateTime'] as Timestamp?)?.toDate();
      return status == 'confirmed' &&
          dateTime != null &&
          dateTime.isAfter(DateTime.now());
    }).toList();
  }

  bool isSessionActive(Map<String, dynamic> booking) {
    final status = booking['status'] as String?;
    final dateTime = (booking['dateTime'] as Timestamp?)?.toDate();
    if (dateTime == null) return false;

    return status == 'confirmed' &&
        dateTime.isBefore(DateTime.now().add(const Duration(minutes: 10)));
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF059669);
      case 'pending':
        return const Color(0xFF92400E);
      case 'cancelled':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFFD1FAE5);
      case 'pending':
        return const Color(0xFFFDE68A);
      case 'cancelled':
        return const Color(0xFFFECACA);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  void joinVideoCall(Map<String, dynamic> booking) {
    if (!isSessionActive(booking)) {
      AppSnackbar.warning(
        title: 'Cannot Join',
        message: 'Session not active yet',
      );
      return;
    }
    // Generate a channel ID from the booking ID
    final channelId = 'booking_${booking['id']}';
    // Student is always the initiator (creates offer first)
    Get.to(() => WebRTCCallScreen(channelId: channelId, isInitiator: true));
  }

  Future<void> cancelSession(Map<String, dynamic> booking) async {
    final status = booking['status'] as String?;
    if (status == 'cancelled') return;

    final bookingId = booking['id'] as String;
    await _service.cancelBooking(bookingId);

    AppSnackbar.success(
      title: 'Booking Cancelled',
      message: 'Your booking has been cancelled',
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
