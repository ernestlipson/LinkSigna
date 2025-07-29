import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Session {
  final String name;
  final String className;
  final String date;
  final String time;
  final String status;
  final bool isActive;

  Session({
    required this.name,
    required this.className,
    required this.date,
    required this.time,
    required this.status,
    required this.isActive,
  });
}

class SessionsController extends GetxController {
  final sessions = <Session>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  void loadSessions() {
    sessions.value = [
      Session(
        name: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: 'Confirmed',
        isActive: true,
      ),
      Session(
        name: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: 'Pending',
        isActive: false,
      ),
      Session(
        name: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: 'Confirmed',
        isActive: true,
      ),
      Session(
        name: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: 'Cancelled',
        isActive: true,
      ),
      Session(
        name: 'Arlene McCoy',
        className: 'Communication Skills',
        date: '2025-04-15',
        time: '10:00 am',
        status: 'Confirmed',
        isActive: true,
      ),
    ];
  }

  void joinVideoCall(Session session) async {
    if (session.isActive && session.status != 'Cancelled') {
      Get.snackbar(
        'Video Call Feature',
        'Video calling feature is coming soon!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Session Not Available',
        'This session is not available for video calling',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void cancelSession(Session session) {
    Get.defaultDialog(
      title: 'Cancel Session',
      middleText: 'Are you sure you want to cancel this session?',
      textConfirm: 'Yes, Cancel',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      cancelTextColor: const Color(0xFF9B197D),
      buttonColor: const Color(0xFF9B197D),
      onConfirm: () {
        // TODO: Implement cancel session logic
        Get.back();
        Get.snackbar(
          'Session Cancelled',
          'Session with ${session.name} has been cancelled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF34C759);
      case 'Pending':
        return const Color(0xFFF6C768);
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFFE6F9F0);
      case 'Pending':
        return const Color(0xFFFDF6E9);
      case 'Cancelled':
        return const Color(0xFFFEE2E2);
      default:
        return Colors.grey.shade100;
    }
  }

  bool isSessionActive(Session session) {
    return session.isActive && session.status != 'Cancelled';
  }
}
