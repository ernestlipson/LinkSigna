import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/call/webrtc_call.screen.dart';
import 'package:sign_language_app/shared/components/app_dialog.component.dart';

import '../../../../infrastructure/dal/services/booking.firestore.service.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';

class InterpreterSessionsController extends GetxController {
  final bookings = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final _service = Get.find<BookingFirestoreService>();
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  Worker? _interpreterIdWorker;

  @override
  void onInit() {
    super.onInit();
    _initializeWithProfileController();
  }

  void _initializeWithProfileController() {
    if (Get.isRegistered<InterpreterProfileController>()) {
      final profileController = Get.find<InterpreterProfileController>();

      // Check if interpreter ID is already available
      if (profileController.interpreterId.value.isNotEmpty) {
        _listen(profileController.interpreterId.value);
      } else {
        // Wait for the interpreter ID to be loaded
        _interpreterIdWorker =
            ever(profileController.interpreterId, (String id) {
          if (id.isNotEmpty) {
            Get.log(
                'InterpreterSessionsController: Interpreter ID loaded: $id');
            _listen(id);
            _interpreterIdWorker?.dispose();
          }
        });
      }
    } else {
      Get.log('Warning: InterpreterProfileController not registered');
    }
  }

  void _listen(String interpreterId) {
    // Cancel existing subscription if any
    _sub?.cancel();

    Get.log(
        'InterpreterSessionsController: Starting to listen for interpreter: $interpreterId');
    _sub = _service.bookingsForInterpreter(interpreterId).listen((list) {
      bookings.assignAll(list);
    });
  }

  List<Map<String, dynamic>> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return bookings;
    return bookings
        .where((b) =>
            (b['studentId'] as String? ?? '').toLowerCase().contains(q) ||
            (b['id'] as String? ?? '').toLowerCase().contains(q))
        .toList();
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
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFFD1FAE5);
      case 'pending':
        return const Color(0xFFFDE68A);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  void joinVideoCall(Map<String, dynamic> booking) {
    if (!isSessionActive(booking)) {
      Get.snackbar('Not Ready', 'Session not active yet',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // Generate a channel ID from the booking ID
    final channelId = 'booking_${booking['id']}';
    // Interpreter is the answerer (waits for offer from student)
    Get.to(() => WebRTCCallScreen(channelId: channelId, isInitiator: false));
  }

  Future<void> cancelSession(Map<String, dynamic> booking) async {
    final status = booking['status'] as String?;
    if (status == 'cancelled') return;

    // Show confirmation dialog
    final confirmed = await AppDialog.showCancelSessionConfirmation();
    if (confirmed != true) return;

    try {
      final bookingId = booking['id'] as String;
      await _service.cancelBooking(bookingId);
      Get.snackbar(
        'Booking Cancelled',
        'The booking has been cancelled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel booking: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> confirmSession(Map<String, dynamic> booking) async {
    final status = booking['status'] as String?;
    if (status != 'pending') return;

    try {
      final bookingId = booking['id'] as String;
      await _service.confirmBooking(bookingId);
      Get.snackbar(
        'Booking Confirmed',
        'The booking has been confirmed',
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

  @override
  void onClose() {
    _sub?.cancel();
    _interpreterIdWorker?.dispose();
    super.onClose();
  }
}
