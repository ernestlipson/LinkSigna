import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/history_session_card.component.dart';
import 'controllers/deaf_history.controller.dart';

class DeafHistoryScreen extends GetView<DeafHistoryController> {
  const DeafHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'History Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.completedBookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No session history',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Completed sessions will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.completedBookings.length,
                  itemBuilder: (context, index) {
                    final booking = controller.completedBookings[index];
                    return _buildSessionCard(booking);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> booking) {
    final isChatActive = controller.isChatActive(booking);
    final interpreterName = booking['interpreterName'] ?? 'Unknown Interpreter';
    final date = controller.getFormattedDate(booking);
    final time = controller.getFormattedTime(booking);
    final rating = booking['rating'] as int?;

    return HistorySessionCard(
      booking: booking,
      otherPartyName: interpreterName,
      date: date,
      time: time,
      rating: rating,
      isChatActive: isChatActive,
      showChatButton: true,
      onMessagePressed: () => controller.messageInterpreter(booking),
    );
  }
}
