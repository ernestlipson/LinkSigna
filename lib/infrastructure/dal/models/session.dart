import 'package:flutter/material.dart';

enum SessionStatus {
  confirmed,
  pending,
  completed,
  cancelled,
}

class Session {
  final String id;
  final String studentName;
  final String className;
  final DateTime date;
  final String time;
  final SessionStatus status;
  final int? rating;
  final String? feedback;

  const Session({
    required this.id,
    required this.studentName,
    required this.className,
    required this.date,
    required this.time,
    required this.status,
    this.rating,
    this.feedback,
  });

  String get statusText {
    switch (status) {
      case SessionStatus.confirmed:
        return 'Confirmed';
      case SessionStatus.pending:
        return 'Pending';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case SessionStatus.confirmed:
        return Colors.green;
      case SessionStatus.pending:
        return Colors.orange;
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.cancelled:
        return Colors.red;
    }
  }
}
