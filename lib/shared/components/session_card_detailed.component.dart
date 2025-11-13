import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import 'app.button.dart';
import 'app_dialog.component.dart';

class SessionCardDetailed extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isActive;
  final String status;
  final Color statusColor;
  final Color statusBgColor;
  final VoidCallback? onJoinVideoCall;
  final VoidCallback? onCancelSession;
  final VoidCallback? onViewFeedback;
  final bool isHistory;

  const SessionCardDetailed({
    super.key,
    required this.booking,
    required this.isActive,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
    this.onJoinVideoCall,
    this.onCancelSession,
    this.onViewFeedback,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime =
        (booking['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6),
            child: Text(
              'Session with ${booking['interpreterName'] ?? 'Unknown Interpreter'}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Divider(color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
            child: Column(
              children: [
                _buildDetailRow(
                  'Date',
                  '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Time',
                  TimeOfDay.fromDateTime(dateTime).format(Get.context!),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isHistory) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: status == 'cancelled'
                              ? 'Cancelled'
                              : 'Join Video Call',
                          onPressed: (isActive && status != 'cancelled')
                              ? (onJoinVideoCall ?? () {})
                              : () {},
                          color: (isActive && status != 'cancelled')
                              ? const Color(0xFF9B197D)
                              : Colors.grey.shade300,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: (isActive && status != 'cancelled')
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomOutlinedButton(
                          text: status == 'cancelled'
                              ? 'Cancelled'
                              : 'Cancel Session',
                          onPressed: status == 'cancelled'
                              ? () {}
                              : () async {
                                  final confirmed = await AppDialog
                                      .showCancelSessionConfirmation();
                                  if (confirmed == true &&
                                      onCancelSession != null) {
                                    onCancelSession!();
                                  }
                                },
                          borderColor: status == 'cancelled'
                              ? Colors.grey.shade400
                              : AppColors.border,
                          textColor: status == 'cancelled'
                              ? Colors.grey.shade500
                              : AppColors.altText,
                        ),
                      ),
                    ],
                  ),
                ] else if (onViewFeedback != null) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'View Feedback',
                      onPressed: onViewFeedback!,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
}
