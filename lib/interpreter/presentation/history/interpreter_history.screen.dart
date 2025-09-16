import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import '../../../../domain/sessions/session_history.model.dart';
import 'controllers/interpreter_history.controller.dart';

class InterpreterHistoryScreen extends GetView<InterpreterHistoryController> {
  const InterpreterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => InterpreterHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'History Session',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final sessions = controller.filteredHistory;

              if (sessions.isEmpty) {
                return const Center(
                  child: Text(
                    'No session history found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _buildSessionCard(session);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionHistoryModel session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Session with ${session.studentName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Rating stars (only show if session is completed and has rating)
            if (session.status == SessionHistoryStatus.completed &&
                session.rating > 0)
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < session.rating ? Icons.star : Icons.star_border,
                    color: index < session.rating
                        ? Colors.amber
                        : Colors.grey[300],
                    size: 20,
                  );
                }),
              ),

            if (session.status == SessionHistoryStatus.completed &&
                session.rating > 0)
              const SizedBox(height: 12),

            // Session details
            _buildDetailRow('Class:', session.className),
            const SizedBox(height: 4),
            _buildDetailRow(
                'Date:', DateFormat('yyyy-MM-dd').format(session.date)),
            const SizedBox(height: 4),
            _buildDetailRow('Time:', session.time),
            const SizedBox(height: 8),

            // Status
            Row(
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(session.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    session.status.value,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusTextColor(session.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // View Feedback button (only show if session is completed and has feedback)
            if (session.status == SessionHistoryStatus.completed &&
                session.hasFeedback) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.viewFeedback(session),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View Feedback',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SessionHistoryStatus status) {
    switch (status) {
      case SessionHistoryStatus.completed:
        return Colors.green.withValues(alpha: 0.1);
      case SessionHistoryStatus.cancelled:
        return Colors.red.withValues(alpha: 0.1);
      case SessionHistoryStatus.noShow:
        return Colors.orange.withValues(alpha: 0.1);
    }
  }

  Color _getStatusTextColor(SessionHistoryStatus status) {
    switch (status) {
      case SessionHistoryStatus.completed:
        return Colors.green[700]!;
      case SessionHistoryStatus.cancelled:
        return Colors.red[700]!;
      case SessionHistoryStatus.noShow:
        return Colors.orange[700]!;
    }
  }
}
