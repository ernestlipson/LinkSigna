import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/users/user.model.dart';

class UserFirestoreService extends GetxService {
  final _col = FirebaseFirestore.instance.collection('users');

  Future<User?> getById(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists) return null;
      return User.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createOrUpdate(User user, {bool isUpdate = false}) async {
    try {
      await _col
          .doc(user.uid)
          .set(user.toMap(isUpdate: isUpdate), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<User> createStudent({
    required String authUid,
    required String displayName,
    required String email,
    String? phone,
    String? university,
    String? universityLevel,
    String? language,
    String? bio,
  }) async {
    try {
      final id = const Uuid().v4();
      final user = User(
        uid: id,
        authUid: authUid,
        role: UserRole.student,
        displayName: displayName,
        email: email,
        phone: phone,
        university: university,
        universityLevel: universityLevel,
        language: language,
        bio: bio,
      );

      await _col
          .doc(id)
          .set(user.toMap(isUpdate: false), SetOptions(merge: true));

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> createInterpreter({
    required String authUid,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? university,
    List<String>? languages,
    List<String>? specializations,
    String? bio,
    String? experience,
    int? years,
  }) async {
    try {
      final id = const Uuid().v4();
      final user = User(
        uid: id,
        authUid: authUid,
        role: UserRole.interpreter,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        university: university,
        languages: languages ?? [],
        specializations: specializations ?? [],
        rating: 0.0,
        isAvailable: false,
        bio: bio,
        experience: experience,
        years: years,
      );

      await _col
          .doc(id)
          .set(user.toMap(isUpdate: false), SetOptions(merge: true));

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getOrCreateStudent({
    required String authUid,
    required String displayName,
    required String email,
    String? phone,
    String? university,
    String? universityLevel,
    String? language,
    String? bio,
  }) async {
    final existing = await findByAuthUid(authUid);
    if (existing != null) return existing;

    return await createStudent(
      authUid: authUid,
      displayName: displayName,
      email: email,
      phone: phone,
      university: university,
      universityLevel: universityLevel,
      language: language,
      bio: bio,
    );
  }

  Future<User?> getOrCreateInterpreter({
    required String authUid,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? university,
    List<String>? languages,
    List<String>? specializations,
    String? bio,
    String? experience,
    int? years,
  }) async {
    final existing = await findByAuthUid(authUid);
    if (existing != null) return existing;

    return await createInterpreter(
      authUid: authUid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      university: university,
      languages: languages,
      specializations: specializations,
      bio: bio,
      experience: experience,
      years: years,
    );
  }

  Future<User?> findByAuthUid(String authUid) async {
    try {
      final q = await _col.where('authUid', isEqualTo: authUid).limit(1).get();
      if (q.docs.isEmpty) return null;
      return User.fromFirestore(q.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> findByEmail(String email) async {
    try {
      final q = await _col.where('email', isEqualTo: email).limit(1).get();
      if (q.docs.isEmpty) return null;
      return User.fromFirestore(q.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> findByPhone(String phone) async {
    try {
      final q = await _col.where('phone', isEqualTo: phone).limit(1).get();
      if (q.docs.isEmpty) return null;
      return User.fromFirestore(q.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getStudents() async {
    try {
      final q = await _col.where('role', isEqualTo: 'student').get();
      return q.docs.map((doc) => User.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getInterpreters() async {
    try {
      final q = await _col.where('role', isEqualTo: 'interpreter').get();
      return q.docs.map((doc) => User.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getAvailableInterpreters() async {
    try {
      final q = await _col
          .where('role', isEqualTo: 'interpreter')
          .where('isAvailable', isEqualTo: true)
          .get();
      return q.docs.map((doc) => User.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<User?> stream(String uid) {
    return _col.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return User.fromFirestore(snap);
    });
  }

  Future<void> updateFields(String uid, Map<String, dynamic> data) async {
    try {
      await _col.doc(uid).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAvailability(String uid, bool isAvailable) async {
    try {
      await updateFields(uid, {'isAvailable': isAvailable});
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getUserRole(String authUid) async {
    try {
      final user = await findByAuthUid(authUid);
      if (user == null) return null;
      return user.role == UserRole.interpreter ? 'interpreter' : 'student';
    } catch (e) {
      rethrow;
    }
  }
}
