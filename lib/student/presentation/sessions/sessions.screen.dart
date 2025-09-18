import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/sessions.controller.dart';
import '../../../domain/sessions/session.model.dart';

class SessionsScreen extends GetView<SessionsController> {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          onChanged: (value) => controller.searchQuery.value = value,
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Sessions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() => ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.filteredSessions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final session = controller.filteredSessions[index];
                    return _buildSessionCard(session);
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    final isActive = controller.isSessionActive(session);
    final statusColor = controller.getStatusColor(session.status);
    final statusBgColor = controller.getStatusBackgroundColor(session.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Title
            Text(
              'Session with Interpreter',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            // Session Details
            _buildDetailRow('Class', session.className),
            const SizedBox(height: 4),
            _buildDetailRow(
              'Date',
              '${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}-${session.startTime.day.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 4),
            _buildDetailRow(
              'Time',
              TimeOfDay.fromDateTime(session.startTime).format(Get.context!),
            ),
            const SizedBox(height: 12),

            // Status
            Row(
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    session.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (isActive && session.status != 'Cancelled')
                        ? () => controller.joinVideoCall(session)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (isActive && session.status != 'Cancelled')
                              ? const Color(0xFF9B197D)
                              : Colors.grey.shade300,
                      foregroundColor:
                          (isActive && session.status != 'Cancelled')
                              ? Colors.white
                              : Colors.grey.shade600,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      session.status == 'Cancelled'
                          ? 'Cancelled'
                          : 'Join Video Call',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: session.status == 'Cancelled'
                        ? null
                        : () async {
                            final confirmed = await _confirmCancel();
                            if (confirmed == true) {
                              controller.cancelSession(session);
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9B197D),
                      disabledForegroundColor: Colors.grey.shade500,
                      side: BorderSide(
                        color: session.status == 'Cancelled'
                            ? Colors.grey.shade400
                            : const Color(0xFF9B197D),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      session.status == 'Cancelled'
                          ? 'Cancelled'
                          : 'Cancel Session',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _confirmCancel() {
    return showDialog<bool>(
      context: Get.context!,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Session'),
        content: const Text('Are you sure you want to cancel this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B197D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
