import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/dal/models/session.dart';

import '../../../../infrastructure/theme/app_theme.dart';
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
          _buildUpcomingSessionsSection(controller),
          const SizedBox(height: 24),
          _buildHistorySection(controller),
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

  Widget _buildUpcomingSessionsSection(InterpreterHomeController controller) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Session',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        controller.changeTab(1), // Navigate to Sessions tab
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (controller.upcomingSessions.isEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Center(
                    child: Text(
                      'No upcoming sessions',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...controller.upcomingSessions.map((session) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSessionCard(session, isUpcoming: true),
                    )),
            ],
          ),
        ));
  }

  Widget _buildHistorySection(InterpreterHomeController controller) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        controller.changeTab(3), // Navigate to History tab
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (controller.historySessions.isEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Center(
                    child: Text(
                      'No session history',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...controller.historySessions.take(3).map((session) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSessionCard(session, isUpcoming: false),
                    )),
            ],
          ),
        ));
  }

  Widget _buildSessionCard(Session session, {required bool isUpcoming}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Title
            Text(
              'Session with ${session.studentName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Rating for completed sessions (history only)
            if (!isUpcoming && session.rating != null) ...[
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < session.rating! ? Icons.star : Icons.star_border,
                    color: index < session.rating!
                        ? Colors.amber
                        : Colors.grey[300],
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 8),
            ],

            // Session details
            _buildDetailRow('Class:', session.className),
            const SizedBox(height: 4),
            _buildDetailRow('Date:', _formatDate(session.date)),
            const SizedBox(height: 4),
            _buildDetailRow('Time:', session.time),
            const SizedBox(height: 8),

            // Status
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: session.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${session.statusText}',
                  style: TextStyle(
                    fontSize: 14,
                    color: session.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if (isUpcoming) ...[
              const SizedBox(height: 16),
              // Action Buttons for upcoming sessions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle join video call
                        Get.snackbar(
                          'Video Call',
                          'Joining video call with ${session.studentName}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Join Video Call',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle cancel session
                        Get.snackbar(
                          'Cancel Session',
                          'Session with ${session.studentName} cancelled',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel Session',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              // View Feedback Button for history
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle view feedback
                    Get.snackbar(
                      'Feedback',
                      'Viewing feedback for session with ${session.studentName}',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'View Feedback',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
