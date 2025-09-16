import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class InterpreterFirestoreService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('interpreter_user');
  final Uuid _uuid = const Uuid();

  /// Create a new interpreter profile. Returns the generated interpreter_id.
  Future<String> createInterpreterProfile(Map<String, dynamic> data) async {
    final String interpreterId = _uuid.v4();
    final docData = {
      ...data,
      'interpreter_id': interpreterId,
      'joinedDate': DateTime.now().toUtc().toIso8601String(),
    };
    await _collection.doc(interpreterId).set(docData);
    return interpreterId;
  }

  /// Fetch a profile by interpreter_id (for login, fast lookup)
  Future<Map<String, dynamic>?> fetchProfileById(String interpreterId) async {
    final doc = await _collection.doc(interpreterId).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  /// Fetch all profiles by email (for login, if no cached id)
  Future<List<Map<String, dynamic>>> fetchProfilesByEmail(String email) async {
    final query = await _collection.where('email', isEqualTo: email).get();
    return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// Real-time stream of a profile by interpreter_id
  Stream<Map<String, dynamic>?> streamProfileById(String interpreterId) {
    return _collection
        .doc(interpreterId)
        .snapshots()
        .map((doc) => doc.data() as Map<String, dynamic>?);
  }

  /// Update profile fields
  Future<void> updateProfile(
      String interpreterId, Map<String, dynamic> data) async {
    await _collection.doc(interpreterId).update(data);
  }
}
