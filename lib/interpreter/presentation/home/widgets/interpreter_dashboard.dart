import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/dashboard/dashboard_section.component.dart';
import 'package:sign_language_app/shared/components/dashboard/empty_state_box.component.dart';
import 'package:sign_language_app/shared/components/session_card_detailed.component.dart';

import '../../sessions/controllers/interpreter_sessions.controller.dart';
import '../../shared/controllers/interpreter_profile.controller.dart';
import '../controllers/interpreter_home.controller.dart';

class InterpreterDashboard extends StatelessWidget {
  const InterpreterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InterpreterHomeController>();
    final sessionsController = Get.put(InterpreterSessionsController());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          DashboardSection(
            title: 'Upcoming Sessions',
            onViewAll: () => controller.changeTab(1),
            child: SizedBox(
              height: 300,
              child: Obx(() {
                final upcomingSessions = sessionsController.bookings
                    .where((booking) {
                      final status = booking['status'] as String? ?? '';
                      return status != 'completed' && status != 'cancelled';
                    })
                    .take(3)
                    .toList();

                if (upcomingSessions.isEmpty) {
                  return const EmptyStateBox(message: 'No upcoming sessions');
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: upcomingSessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = upcomingSessions[index];
                    final isActive =
                        sessionsController.isSessionActive(booking);
                    final status = booking['status'] as String? ?? 'pending';
                    final statusColor =
                        sessionsController.getStatusColor(status);
                    final statusBgColor =
                        sessionsController.getStatusBg(status);

                    return SessionCardDetailed(
                      booking: booking,
                      isActive: isActive,
                      status: status,
                      statusColor: statusColor,
                      statusBgColor: statusBgColor,
                      onJoinVideoCall: () =>
                          sessionsController.joinVideoCall(booking),
                      onCancelSession: () =>
                          sessionsController.cancelSession(booking),
                      onConfirmSession: () =>
                          sessionsController.confirmSession(booking),
                      isHistory: false,
                      isInterpreterView: true,
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          DashboardSection(
            title: 'History',
            onViewAll: () => controller.changeTab(3),
            child: SizedBox(
              height: 300,
              child: Obx(() {
                final historySessions = sessionsController.bookings
                    .where((booking) {
                      final status = booking['status'] as String? ?? '';
                      return status == 'completed';
                    })
                    .take(3)
                    .toList();

                if (historySessions.isEmpty) {
                  return const EmptyStateBox(message: 'No past sessions');
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: historySessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = historySessions[index];
                    final status = booking['status'] as String? ?? 'completed';
                    final statusColor =
                        sessionsController.getStatusColor(status);
                    final statusBgColor =
                        sessionsController.getStatusBg(status);

                    return SessionCardDetailed(
                      booking: booking,
                      isActive: false,
                      status: status,
                      statusColor: statusColor,
                      statusBgColor: statusBgColor,
                      onViewFeedback: () {
                        Get.snackbar(
                          'Feedback',
                          'Viewing feedback for session with ${booking['studentName']}',
                        );
                      },
                      isHistory: true,
                      isInterpreterView: true,
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final profileController = Get.find<InterpreterProfileController>();

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome ${profileController.firstName}',
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
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      );
    });
  }
}
