import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../infrastructure/dal/models/interpreter.model.dart';

class InterpreterService {
  // --- Firebase Interaction Examples ---

  final FirebaseFirestore _db = FirebaseFirestore.instance;

// 1. Adding a new Interpreter

  Future<void> addInterpreter(Interpreter interpreter) async {
    try {
      await _db.collection('interpreter_user').add(interpreter.toFirestore());
      Get.log('Interpreter added successfully!');
    } catch (e) {
      Get.log('Error adding interpreter: $e');
    }
  }

// 2. Getting all Interpreters (one-time fetch)

  Future<List<Interpreter>> getAllInterpreters() async {
    try {
      QuerySnapshot querySnapshot =
          await _db.collection('interpreter_user').get();
      return querySnapshot.docs
          .map((doc) => Interpreter.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.log('Error getting interpreters: $e');
      return [];
    }
  }

// 3. Getting a single Interpreter by ID

  Future<Interpreter?> getInterpreterById(String interpreterId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('interpreter_user').doc(interpreterId).get();
      if (doc.exists) {
        return Interpreter.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      Get.log('Error getting interpreter by ID: $e');
      return null;
    }
  }

// 4. Listening to real-time changes for all interpreters (e.g., for a list screen)

  Stream<List<Interpreter>> streamAllInterpreters() {
    return _db.collection('interpreter_user').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Interpreter.fromFirestore(doc)).toList());
  }

  Future<void> setBookingStatus(
      {required String interpreterId, required bool isBooked}) async {
    try {
      await _db.collection('interpreter_user').doc(interpreterId).update({
        'isBooked': isBooked,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.log('Error updating booking status: $e');
      rethrow;
    }
  }
}
