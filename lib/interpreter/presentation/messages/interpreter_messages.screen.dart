import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/theme/app_theme.dart';
import 'controllers/interpreter_messages.controller.dart';

class InterpreterMessagesScreen extends StatelessWidget {
  const InterpreterMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterpreterMessagesController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messages from Student',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF232323),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: controller.sessions.length,
                    itemBuilder: (context, index) {
                      final session = controller.sessions[index];
                      return SessionCard(
                        session: session,
                        onOpenChat: () => controller.openChat(session),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  final SessionMessage session;
  final VoidCallback onOpenChat;

  const SessionCard({
    super.key,
    required this.session,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = session.status == SessionStatus.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF232323),
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Class:', session.className),
          const SizedBox(height: 4),
          _buildInfoRow('Date:', session.date),
          const SizedBox(height: 4),
          _buildInfoRow('Time:', session.time),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Status:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF232323),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isActive ? 'Chat Active (within 24)' : 'Chat Expired',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isActive ? onOpenChat : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? primaryColor : Colors.grey[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: isActive ? 2 : 0,
              ),
              child: Text(
                'Open Chat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF232323),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
