import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/infrastructure/dal/models/session.dart';

import '../../../../infrastructure/dal/services/booking.firestore.service.dart';
import '../../../../infrastructure/navigation/routes.dart';
import '../../settings/controllers/interpreter_settings.controller.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';

class InterpreterHomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxList<Session> upcomingSessions = <Session>[].obs;
  final RxList<Session> historySessions = <Session>[].obs;
  final RxList<Map<String, dynamic>> pendingBookings =
      <Map<String, dynamic>>[].obs;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  Worker? _interpreterIdWorker;
  late final BookingFirestoreService _bookingService;

  @override
  void onInit() {
    super.onInit();
    _ensureControllers();
    _bookingService = Get.find<BookingFirestoreService>();
    _initializeWithProfileController();
  }

  void _ensureControllers() {
    if (!Get.isRegistered<InterpreterSettingsController>()) {
      Get.lazyPut<InterpreterSettingsController>(
        () => InterpreterSettingsController(),
        fenix: true,
      );
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void _initializeWithProfileController() {
    if (Get.isRegistered<InterpreterProfileController>()) {
      final profileController = Get.find<InterpreterProfileController>();

      // Check if interpreter ID is already available
      if (profileController.interpreterId.value.isNotEmpty) {
        _listenToSessions(profileController.interpreterId.value);
      } else {
        // Wait for the interpreter ID to be loaded
        _interpreterIdWorker =
            ever(profileController.interpreterId, (String id) {
          if (id.isNotEmpty) {
            Get.log('InterpreterHomeController: Interpreter ID loaded: $id');
            _listenToSessions(id);
            _interpreterIdWorker?.dispose();
          }
        });
      }
    } else {
      Get.log('Warning: InterpreterProfileController not registered');
    }
  }

  void _listenToSessions(String interpreterId) {
    _sub?.cancel();

    Get.log(
        'InterpreterHomeController: Starting to listen for interpreter: $interpreterId');
    _sub = _bookingService.bookingsForInterpreter(interpreterId).listen((list) {
      final now = DateTime.now();
      final upcoming = <Session>[];
      final history = <Session>[];
      final pending = <Map<String, dynamic>>[];

      for (final booking in list) {
        final dateTime = (booking['dateTime'] as Timestamp?)?.toDate();
        if (dateTime == null) continue;

        final status = booking['status'] as String? ?? 'pending';

        // Separate pending bookings for approval
        if (status == 'pending') {
          pending.add(booking);
        }

        // Only show confirmed bookings in the future as upcoming
        if (status == 'confirmed' && dateTime.isAfter(now)) {
          upcoming.add(_toDashboardSession(booking, dateTime));
        } else if (status == 'cancelled' ||
            status == 'completed' ||
            dateTime.isBefore(now)) {
          history.add(_toDashboardSession(booking, dateTime));
        }
      }

      pendingBookings.assignAll(pending
        ..sort((a, b) {
          final aTime =
              (a['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
          final bTime =
              (b['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
          return aTime.compareTo(bTime);
        }));
      upcomingSessions
          .assignAll(upcoming..sort((a, b) => a.date.compareTo(b.date)));
      historySessions
          .assignAll(history..sort((a, b) => b.date.compareTo(a.date)));
    });
  }

  Session _toDashboardSession(Map<String, dynamic> booking, DateTime dateTime) {
    // You may want to fetch student name from another service if needed
    return Session(
      id: booking['id'] as String? ?? '',
      studentName: booking['studentId'] as String? ??
          'Unknown', // Replace with actual student name if available
      className: 'Booking', // Bookings don't have className
      date: dateTime,
      time: _formatTime(dateTime),
      status: _toSessionStatus(booking['status'] as String? ?? 'pending'),
      rating: null,
      feedback: null,
    );
  }

  SessionStatus _toSessionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return SessionStatus.confirmed;
      case 'pending':
        return SessionStatus.pending;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'completed':
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

  // Public methods for booking actions
  Future<void> confirmBooking(String bookingId) async {
    try {
      await _bookingService.confirmBooking(bookingId);
      Get.snackbar(
        'Booking Confirmed',
        'You have confirmed this booking',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to confirm booking: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    try {
      await _bookingService.cancelBooking(bookingId);
      Get.snackbar(
        'Booking Rejected',
        'You have rejected this booking',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject booking: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    _interpreterIdWorker?.dispose();
    super.onClose();
  }

  Future<void> logout() async {
    try {
      // 1. Cancel all active Firestore subscriptions first
      _sub?.cancel();

      // 2. Clean up profile controller subscriptions
      if (Get.isRegistered<InterpreterProfileController>()) {
        final profileController = Get.find<InterpreterProfileController>();
        profileController.onClose();
      }

      // 3. Clean up settings controller
      if (Get.isRegistered<InterpreterSettingsController>()) {
        final settingsController = Get.find<InterpreterSettingsController>();
        settingsController.onClose();
      }

      final prefs = await SharedPreferences.getInstance();

      // 4. Clear interpreter login status
      await prefs.setBool('interpreter_logged_in', false);
      await prefs.remove('userName');
      await prefs.remove('userEmail');
      await prefs.remove('interpreter_id');
      await prefs.remove('interpreter_email');
      await prefs.remove('interpreter_name');

      // 5. Sign out from Firebase Auth to stop all Firestore listeners
      await FirebaseAuth.instance.signOut();

      // 6. Delete all GetX controllers to ensure complete cleanup
      Get.delete<InterpreterProfileController>(force: true);
      Get.delete<InterpreterSettingsController>(force: true);
      Get.delete<InterpreterHomeController>(force: true);

      Get.snackbar(
        'Logout',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 7. Navigate back to signup screen
      Get.offAllNamed(Routes.initialRoute);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Jump to Settings screen and ensure profile tab opens
  void goToProfileTab() {
    selectedIndex.value = 4; // Settings tab index
    if (Get.isRegistered<InterpreterSettingsController>()) {
      Get.find<InterpreterSettingsController>().selectedTab.value =
          0; // Profile sub-tab
    }
  }
}
