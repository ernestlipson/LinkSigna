import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/history_session_card.component.dart';
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final bookings = controller.filteredHistory;

              if (bookings.isEmpty) {
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
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _buildSessionCard(booking);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> booking) {
    final studentName = booking['studentName'] ?? 'Unknown Student';
    final date = controller.getFormattedDate(booking);
    final time = controller.getFormattedTime(booking);
    final rating = booking['rating'] as int?;

    return HistorySessionCard(
      booking: booking,
      otherPartyName: studentName,
      date: date,
      time: time,
      rating: rating,
      showChatButton: false,
    );
  }
}
