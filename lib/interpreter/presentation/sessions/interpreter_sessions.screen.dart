import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/search_bar.component.dart';
import '../../../shared/components/session_card_detailed.component.dart';
import 'controllers/interpreter_sessions.controller.dart';

class InterpreterSessionsScreen extends GetView<InterpreterSessionsController> {
  const InterpreterSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => InterpreterSessionsController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSearch(),
            Expanded(
              child: _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      child: SearchBarComponent(
        onChanged: (value) => controller.searchQuery.value = value,
      ),
    );
  }

  Widget _buildList() {
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
            child: Obx(() {
              final upcomingSessions = controller.filtered.where((booking) {
                final status = booking['status'] as String? ?? '';
                return status != 'completed' && status != 'cancelled';
              }).toList();

              if (controller.filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No sessions yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Wait for students to book sessions',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (upcomingSessions.isEmpty) {
                return Center(
                  child: Text(
                    'No upcoming sessions',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: upcomingSessions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = upcomingSessions[index];
                  final isActive = controller.isSessionActive(booking);
                  final status = booking['status'] as String? ?? 'pending';
                  final statusColor = controller.getStatusColor(status);
                  final statusBgColor = controller.getStatusBg(status);

                  return SessionCardDetailed(
                    booking: booking,
                    isActive: isActive,
                    status: status,
                    statusColor: statusColor,
                    statusBgColor: statusBgColor,
                    onJoinVideoCall: () => controller.joinVideoCall(booking),
                    onCancelSession: () => controller.cancelSession(booking),
                    onConfirmSession: () => controller.confirmSession(booking),
                    isHistory: false,
                    isInterpreterView: true,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
