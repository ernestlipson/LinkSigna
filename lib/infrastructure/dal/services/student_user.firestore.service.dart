import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../domain/users/student_user.model.dart';

class StudentUserFirestoreService extends GetxService {
  final _col = FirebaseFirestore.instance.collection('users');
  // NOTE: If you later need to query by createdAt or university_level add a composite index
  // in Firestore console (Indexes). For simple .doc(id) access no index is required.

  Future<StudentUser?> getById(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists) return null;
      return StudentUser.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createOrUpdate(StudentUser user, {bool isUpdate = false}) async {
    try {
      await _col
          .doc(user.uid)
          .set(user.toMap(isUpdate: isUpdate), SetOptions(merge: true));
    } catch (e) {
      // Surface error upstream; controller will decide how to show snackbar
      rethrow;
    }
  }

  Future<StudentUser> createNew(StudentUser user) async {
    try {
      final docRef = await _col.add(user.toMap());
      // Return a copy with the generated document id (authUid preserved)
      return StudentUser(
        uid: docRef.id,
        authUid: user.authUid,
        displayName: user.displayName,
        email: user.email,
        phone: user.phone,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
        universityLevel: user.universityLevel,
        language: user.language,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<StudentUser?> findByAuthUid(String authUid) async {
    final q = await _col.where('authUid', isEqualTo: authUid).limit(1).get();
    if (q.docs.isEmpty) return null;
    return StudentUser.fromFirestore(q.docs.first);
  }

  Future<StudentUser?> findByPhone(String phone) async {
    final q = await _col.where('phone', isEqualTo: phone).limit(1).get();
    if (q.docs.isEmpty) return null;
    return StudentUser.fromFirestore(q.docs.first);
  }

  Stream<StudentUser?> stream(String uid) {
    return _col.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return StudentUser.fromFirestore(snap);
    });
  }

  Future<void> updateFields(String uid, Map<String, dynamic> data) async {
    try {
      await _col.doc(uid).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow; // Keep simple; calling layer wraps with UI feedback
    }
  }
}
