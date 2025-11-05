import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
}
