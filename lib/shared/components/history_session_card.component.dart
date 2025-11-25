import 'package:flutter/material.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';

class HistorySessionCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String otherPartyName;
  final String date;
  final String time;
  final int? rating;
  final bool isChatActive;
  final VoidCallback? onMessagePressed;
  final bool showChatButton;
  final String? buttonText;

  const HistorySessionCard({
    super.key,
    required this.booking,
    required this.otherPartyName,
    required this.date,
    required this.time,
    this.rating,
    this.isChatActive = false,
    this.onMessagePressed,
    this.showChatButton = false,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            // Session Title
            Text(
              'Session with $otherPartyName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Rating stars (only show if has rating)
            if (rating != null && rating! > 0) ...[
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating! ? Icons.star : Icons.star_border,
                    color: index < rating! ? Colors.amber : Colors.grey[300],
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],

            // Session Details
            _buildSessionDetail('Date', date),
            const SizedBox(height: 4),
            _buildSessionDetail('Time', time),
            const SizedBox(height: 4),
            _buildSessionDetail('Status', '• Completed', isStatus: true),

            // Chat Status and Button (only for student view)
            if (showChatButton) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isChatActive ? Colors.pink[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isChatActive ? 'Chat Active (within 24h)' : 'Chat Expired',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isChatActive ? Colors.pink[700] : Colors.red[700],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isChatActive ? onMessagePressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isChatActive ? AppColors.primary : Colors.grey[300],
                    foregroundColor:
                        isChatActive ? Colors.white : Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    buttonText ?? 'Message Interpreter',
                    style: const TextStyle(
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

  Widget _buildSessionDetail(String label, String value,
      {bool isStatus = false}) {
    return Row(
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
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        if (isStatus) const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
