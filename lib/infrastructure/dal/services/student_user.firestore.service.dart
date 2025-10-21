import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
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
      final id = const Uuid().v4();
      await _col
          .doc(id)
          .set(user.toMap(isUpdate: false), SetOptions(merge: true));
      return StudentUser(
        uid: id,
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

  Future<StudentUser> getOrCreateByAuthUid({
    required String authUid,
    String? displayName,
    String? phone,
    String? email,
    String? university,
    String? universityLevel,
    String? language,
    String? bio,
  }) async {
    final existing = await findByAuthUid(authUid);
    if (existing != null) return existing;

    final id = const Uuid().v4();
    final user = StudentUser(
      uid: id,
      authUid: authUid,
      displayName: displayName,
      email: email,
      phone: phone,
      avatarUrl: null,
      bio: bio,
      university: university,
      universityLevel: universityLevel,
      language: language,
    );
    await _col
        .doc(id)
        .set(user.toMap(isUpdate: false), SetOptions(merge: true));
    return user;
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
