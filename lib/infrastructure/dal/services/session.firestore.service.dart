import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../domain/sessions/session.model.dart';

class SessionFirestoreService extends GetxService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('sessions');

  Stream<List<SessionModel>> sessionsForStudent(String studentId) {
    return _col
        .where('studentId', isEqualTo: studentId)
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SessionModel.fromFirestore(d.id, d.data()))
            .toList());
  }

  Stream<List<SessionModel>> sessionsForInterpreter(String interpreterId) {
    return _col
        .where('interpreterId', isEqualTo: interpreterId)
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SessionModel.fromFirestore(d.id, d.data()))
            .toList());
  }

  Future<String> createSession({
    required String studentId,
    required String interpreterId,
    required String className,
    required DateTime startTime,
  }) async {
    final doc = _col.doc();
    final channelId = 'ch_${doc.id}';
    final sessionId = doc.id;
    await doc.set({
      'studentId': studentId,
      'interpreterId': interpreterId,
      'className': className,
      'startTime': startTime.toUtc().millisecondsSinceEpoch,
      'date': startTime.toUtc(),
      'sessionId': sessionId,
      'status': 'Pending',
      'channelId': channelId,
      'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    });
    return doc.id;
  }

  Future<void> updateStatus(String id, String status) async {
    await _col.doc(id).update({
      'status': status,
      'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    });
  }
}
