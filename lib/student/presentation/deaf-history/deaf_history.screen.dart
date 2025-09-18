import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import 'controllers/deaf_history.controller.dart';

class DeafHistoryScreen extends GetView<DeafHistoryController> {
  const DeafHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Text(
            'History Session',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: controller.sessions.length,
                itemBuilder: (context, index) {
                  final session = controller.sessions[index];
                  return _buildSessionCard(session);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionData session) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Title
            Text(
              'Session with ${session.interpreterName}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),

            // Session Details
            _buildSessionDetail('Class', session.className),
            _buildSessionDetail('Date', session.date),
            _buildSessionDetail('Time', session.time),
            _buildSessionDetail('Status', '• Completed', isStatus: true),
            SizedBox(height: 12),

            // Chat Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: session.isChatActive ? Colors.pink[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                session.isChatActive
                    ? 'Chat Active (within 24)'
                    : 'Chat Expired',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      session.isChatActive ? Colors.pink[700] : Colors.red[700],
                ),
              ),
            ),
            SizedBox(height: 12),

            // Message Interpreter Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: session.isChatActive
                    ? () => controller.messageInterpreter(session)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: session.isChatActive
                      ? AppColors.primary
                      : Colors.grey[300],
                  foregroundColor:
                      session.isChatActive ? Colors.white : Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Message Interpreter',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDetail(String label, String value,
      {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          if (isStatus)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          if (isStatus) SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// Data model for session
class SessionData {
  final String interpreterName;
  final String className;
  final String date;
  final String time;
  final bool isChatActive;

  SessionData({
    required this.interpreterName,
    required this.className,
    required this.date,
    required this.time,
    required this.isChatActive,
  });
}
