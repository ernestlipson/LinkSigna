import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/search_bar.component.dart';
import '../../../shared/components/session_card_detailed.component.dart';
import 'controllers/sessions.controller.dart';

class SessionsScreen extends GetView<SessionsController> {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SearchBarComponent(
        onChanged: (value) => controller.searchQuery.value = value,
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
            child: Obx(() {
              final upcomingSessions =
                  controller.filteredSessions.where((booking) {
                final status = booking['status'] as String? ?? '';
                return status != 'completed' && status != 'cancelled';
              }).toList();

              if (controller.bookings.isEmpty) {
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
                        'Book an interpreter to get started',
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
                  final session = upcomingSessions[index];
                  final isActive = controller.isSessionActive(session);
                  final status = session['status'] as String? ?? 'pending';
                  final statusColor = controller.getStatusColor(status);
                  final statusBgColor =
                      controller.getStatusBackgroundColor(status);

                  return SessionCardDetailed(
                    booking: session,
                    isActive: isActive,
                    status: status,
                    statusColor: statusColor,
                    statusBgColor: statusBgColor,
                    onJoinVideoCall: () => controller.joinVideoCall(session),
                    onCancelSession: () => controller.cancelSession(session),
                    isHistory: false,
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
