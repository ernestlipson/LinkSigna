class SessionModel {
  final String id;
  final String studentId;
  final String interpreterId;
  final String className;
  final DateTime startTime;
  final String status; // Pending | Confirmed | Cancelled
  final String channelId;

  SessionModel({
    required this.id,
    required this.studentId,
    required this.interpreterId,
    required this.className,
    required this.startTime,
    required this.status,
    required this.channelId,
  });

  factory SessionModel.fromFirestore(String id, Map<String, dynamic> data) {
    return SessionModel(
      id: id,
      studentId: data['studentId'] ?? '',
      interpreterId: data['interpreterId'] ?? '',
      className: data['className'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(
        (data['startTime'] ?? DateTime.now().millisecondsSinceEpoch) as int,
        isUtc: true,
      ).toLocal(),
      status: data['status'] ?? 'Pending',
      channelId: data['channelId'] ?? id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'interpreterId': interpreterId,
      'className': className,
      'startTime': startTime.toUtc().millisecondsSinceEpoch,
      'status': status,
      'channelId': channelId,
      'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    };
  }
}
