import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_language_app/shared/call/webrtc_call.screen.dart';
import '../../../../infrastructure/dal/services/booking.firestore.service.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';

class InterpreterSessionsController extends GetxController {
  final bookings = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final _service = Get.find<BookingFirestoreService>();
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  late final String _interpreterId;

  @override
  void onInit() {
    super.onInit();
    _interpreterId = _resolveInterpreterId();
    // Do not start listening if we only have a fallback id (no real interpreter doc).
    // Starting a query with a non-existent/fallback interpreter doc id causes
    // Firestore rules to deny the request (see security rules which validate
    // access based on the referenced interpreter document). Only listen when
    // we have a valid interpreter id.
    if (!_interpreterId.startsWith('interpreter_fallback_')) {
      _listen();
    } else {
      Get.log(
          'InterpreterSessionsController: not listening because no interpreter id is available');
    }
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
    _sub = _service.bookingsForInterpreter(_interpreterId).listen((list) {
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
    super.onClose();
  }
}
