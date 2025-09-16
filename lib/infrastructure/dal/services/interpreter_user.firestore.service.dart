import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/users/interpreter_user.model.dart';

class InterpreterUserFirestoreService extends GetxService {
  final _col = FirebaseFirestore.instance.collection('interpreter_user');

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
  }) async {
    try {
      final id = const Uuid().v4();
      final user = InterpreterUser(
        interpreterID: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        languages: [], // Default empty list
        specializations: [], // Default empty list
        rating: 0.0, // Default rating
        bio: null, // No default bio
        isAvailable: false, // Default to unavailable
        profilePictureUrl: null, // No default profile picture
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
  }) async {
    final existing = await findByEmail(email);
    if (existing != null) return existing;

    return await createNew(
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      email: email,
      phone: phone,
    );
  }

  Future<InterpreterUser?> findByEmail(String email) async {
    try {
      final q = await _col.where('email', isEqualTo: email).limit(1).get();
      if (q.docs.isEmpty) return null;
      return InterpreterUser.fromFirestore(q.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<InterpreterUser?> findByPhone(String phone) async {
    try {
      final q = await _col.where('phone', isEqualTo: phone).limit(1).get();
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
      final q = await _col.where('isAvailable', isEqualTo: true).get();
      return q.docs.map((doc) => InterpreterUser.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
