import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/users/interpreter_user.model.dart';

class InterpreterUserFirestoreService extends GetxService {
  final _col = FirebaseFirestore.instance.collection('interpreters');

  Future<InterpreterUser?> getById(String interpreterID) async {
    try {
      final doc = await _col.doc(interpreterID).get();
      if (!doc.exists) return null;
      return InterpreterUser.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createOrUpdate(InterpreterUser user,
      {bool isUpdate = false}) async {
    try {
      await _col
          .doc(user.interpreterID)
          .set(user.toMap(isUpdate: isUpdate), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<InterpreterUser> createNew({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? authUid,
    String? university,
  }) async {
    try {
      final id = const Uuid().v4();
      final user = InterpreterUser(
        interpreterID: id,
        authUid: authUid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        university: university,
        languages: [],
        specializations: [],
        rating: 0.0,
        bio: null,
        isAvailable: false,
        profilePictureUrl: null,
      );

      await _col
          .doc(id)
          .set(user.toMap(isUpdate: false), SetOptions(merge: true));

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<InterpreterUser?> getOrCreateByEmail({
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    String? authUid,
    String? university,
  }) async {
    final existing = await findByEmail(email);
    if (existing != null) return existing;

    return await createNew(
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      email: email,
      phone: phone,
      authUid: authUid,
      university: university,
    );
  }

  Future<InterpreterUser?> getOrCreateByAuthUid({
    required String authUid,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? university,
  }) async {
    try {
      final q = await _col
          .where('authUid', isEqualTo: authUid)
          .where('role', isEqualTo: 'interpreter')
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        return InterpreterUser.fromFirestore(q.docs.first);
      }

      if (email != null && firstName != null && lastName != null) {
        return await createNew(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          authUid: authUid,
          university: university,
        );
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<InterpreterUser?> findByAuthUid(String authUid) async {
    try {
      final q = await _col
          .where('authUid', isEqualTo: authUid)
          .where('role', isEqualTo: 'interpreter')
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      return InterpreterUser.fromFirestore(q.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<InterpreterUser?> findByEmail(String email) async {
    try {
      final q = await _col
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'interpreter')
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      return InterpreterUser.fromFirestore(q.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<InterpreterUser?> findByPhone(String phone) async {
    try {
      final q = await _col
          .where('phone', isEqualTo: phone)
          .where('role', isEqualTo: 'interpreter')
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      return InterpreterUser.fromFirestore(q.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  Stream<InterpreterUser?> stream(String interpreterID) {
    return _col.doc(interpreterID).snapshots().map((snap) {
      if (!snap.exists) return null;
      return InterpreterUser.fromFirestore(snap);
    });
  }

  Future<void> updateFields(
      String interpreterID, Map<String, dynamic> data) async {
    try {
      await _col.doc(interpreterID).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAvailability(
      String interpreterID, bool isAvailable) async {
    try {
      await updateFields(interpreterID, {'isAvailable': isAvailable});
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InterpreterUser>> getAvailableInterpreters() async {
    try {
      final q = await _col
          .where('isAvailable', isEqualTo: true)
          .where('role', isEqualTo: 'interpreter')
          .get();
      return q.docs.map((doc) => InterpreterUser.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
