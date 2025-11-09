import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../domain/users/user.model.dart';

class InterpreterService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Pagination constants
  static const int pageSize = 20;

  // Query the unified 'users' collection for role == 'interpreter'
  Future<void> addInterpreter(User interpreter) async {
    try {
      await _db.collection('users').add(interpreter.toMap());
      Get.log('Interpreter added successfully!');
    } catch (e) {
      Get.log('Error adding interpreter: $e');
    }
  }

  // Get paginated interpreters (one-time fetch)
  Future<List<User>> getAllInterpreters({
    DocumentSnapshot? lastDocument,
    int limit = pageSize,
  }) async {
    try {
      Query query = _db
          .collection('users')
          .where('role', isEqualTo: 'interpreter')
          .orderBy('updatedAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    } catch (e) {
      Get.log('Error getting interpreters: $e');
      return [];
    }
  }

  // Get a single Interpreter by ID from unified users collection
  Future<User?> getInterpreterById(String interpreterId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('users').doc(interpreterId).get();
      if (doc.exists) {
        final user = User.fromFirestore(doc);
        if (user.isInterpreter) {
          return user;
        }
      }
      return null;
    } catch (e) {
      Get.log('Error getting interpreter by ID: $e');
      return null;
    }
  }

  // Real-time stream for all interpreters with pagination support
  Stream<List<User>> streamAllInterpreters({int limit = pageSize}) {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'interpreter')
        // .orderBy('updatedAt', descending: true) // Temporarily commented until index is created
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => User.fromFirestore(doc)).toList());
  }

  // Stream for paginated results (useful for infinite scroll)
  Stream<List<User>> streamInterpretersPaginated({
    required DocumentSnapshot? lastDocument,
    int limit = pageSize,
  }) {
    Query query = _db
        .collection('users')
        .where('role', isEqualTo: 'interpreter')
        .orderBy('updatedAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => User.fromFirestore(doc)).toList());
  }

  // Update booking status (sets isAvailable to false when booked)
  Future<void> setBookingStatus(
      {required String interpreterId, required bool isBooked}) async {
    try {
      await _db.collection('users').doc(interpreterId).update({
        'isAvailable': !isBooked, // When booked, set available to false
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.log('Error updating booking status: $e');
      rethrow;
    }
  }

  // Get available interpreters only
  Stream<List<User>> streamAvailableInterpreters({int limit = pageSize}) {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'interpreter')
        .where('isAvailable', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => User.fromFirestore(doc)).toList());
  }
}
