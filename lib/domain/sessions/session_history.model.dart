class SessionHistoryModel {
  final String id;
  final String studentId;
  final String studentName;
  final String interpreterId;
  final String className;
  final DateTime date;
  final String time;
  final SessionHistoryStatus status;
  final int rating; // 1-5 stars, 0 if not rated
  final bool hasFeedback;
  final String? feedbackText;

  SessionHistoryModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.interpreterId,
    required this.className,
    required this.date,
    required this.time,
    required this.status,
    this.rating = 0,
    this.hasFeedback = false,
    this.feedbackText,
  });

  factory SessionHistoryModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return SessionHistoryModel(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? 'Unknown Student',
      interpreterId: data['interpreterId'] ?? '',
      className: data['className'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(
        (data['date'] ?? DateTime.now().millisecondsSinceEpoch) as int,
        isUtc: true,
      ).toLocal(),
      time: data['time'] ?? '',
      status: SessionHistoryStatus.fromString(data['status'] ?? 'completed'),
      rating: data['rating'] ?? 0,
      hasFeedback: data['hasFeedback'] ?? false,
      feedbackText: data['feedbackText'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'interpreterId': interpreterId,
      'className': className,
      'date': date.toUtc().millisecondsSinceEpoch,
      'time': time,
      'status': status.value,
      'rating': rating,
      'hasFeedback': hasFeedback,
      'feedbackText': feedbackText,
      'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    };
  }
}

enum SessionHistoryStatus {
  completed('Completed'),
  cancelled('Cancelled'),
  noShow('No Show');

  const SessionHistoryStatus(this.value);
  final String value;

  static SessionHistoryStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return SessionHistoryStatus.completed;
      case 'cancelled':
        return SessionHistoryStatus.cancelled;
      case 'no show':
        return SessionHistoryStatus.noShow;
      default:
        return SessionHistoryStatus.completed;
    }
  }
}
