import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sign_language_app/shared/components/dashboard/dashboard_section.component.dart';
import 'package:sign_language_app/shared/components/dashboard/empty_state_box.component.dart';
import 'package:sign_language_app/shared/components/dashboard/session_card.component.dart';

import '../controllers/interpreter_home.controller.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';

class InterpreterDashboard extends StatelessWidget {
  const InterpreterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InterpreterHomeController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          // Pending Bookings Section - NEW
          _buildPendingBookingsSection(controller),
          const SizedBox(height: 24),
          DashboardSection(
            title: 'Upcoming Session',
            onViewAll: () => controller.changeTab(1),
            child: Obx(() {
              final list = controller.upcomingSessions;
              if (list.isEmpty) {
                return const EmptyStateBox(message: 'No upcoming sessions');
              }
              return Column(
                children: list
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SessionCard(
                            session: s,
                            isUpcoming: true,
                            onJoin: () => Get.snackbar('Video Call',
                                'Joining video call with ${s.studentName}'),
                            onCancel: () => Get.snackbar('Cancel Session',
                                'Session with ${s.studentName} cancelled'),
                          ),
                        ))
                    .toList(),
              );
            }),
          ),
          const SizedBox(height: 24),
          DashboardSection(
            title: 'History',
            onViewAll: () => controller.changeTab(3),
            child: Obx(() {
              final list = controller.historySessions;
              if (list.isEmpty) {
                return const EmptyStateBox(message: 'No session history');
              }
              return Column(
                children: list
                    .take(3)
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SessionCard(
                            session: s,
                            isUpcoming: false,
                            onViewFeedback: () => Get.snackbar(
                              'Feedback',
                              'Viewing feedback for session with ${s.studentName}',
                            ),
                          ),
                        ))
                    .toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final profileController = Get.find<InterpreterProfileController>();

    return Obx(() {
      final user = profileController.profile.value;
      final userName = user?.displayName ?? 'Interpreter';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome $userName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Here\'s what\'s happening with your interpreter sessions today.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPendingBookingsSection(InterpreterHomeController controller) {
    return Obx(() {
      final pendingList = controller.pendingBookings;

      if (pendingList.isEmpty) {
        return const SizedBox.shrink(); // Hide section if no pending bookings
      }

      return DashboardSection(
        title: 'Pending Bookings (${pendingList.length})',
        onViewAll: () => controller.changeTab(1), // Go to sessions tab
        child: Column(
          children: pendingList.take(3).map((booking) {
            return _buildPendingBookingCard(booking, controller);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildPendingBookingCard(
      Map<String, dynamic> booking, InterpreterHomeController controller) {
    final dateTime =
        (booking['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
    final studentId = booking['studentId'] as String? ?? 'Unknown';
    final bookingId = booking['id'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PENDING APPROVAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Student: $studentId',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                TimeOfDay.fromDateTime(dateTime).format(Get.context!),
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.confirmBooking(bookingId),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.rejectBooking(bookingId),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
