import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BookingFirestoreService extends GetxService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('bookings');

  /// Create a new booking with denormalized user information
  Future<String> createBooking({
    required String studentId,
    required String interpreterId,
    required DateTime dateTime,
    String status = 'pending',
    String? studentName,
    String? studentEmail,
    String? interpreterName,
    String? interpreterEmail,
  }) async {
    final doc = _col.doc();
    await doc.set({
      'studentId': studentId,
      'interpreterId': interpreterId,
      'studentName': studentName ?? 'Unknown Student',
      'studentEmail': studentEmail ?? '',
      'interpreterName': interpreterName ?? 'Unknown Interpreter',
      'interpreterEmail': interpreterEmail ?? '',
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Check if a student has an active booking with an interpreter
  Future<bool> hasActiveBooking({
    required String studentId,
    required String interpreterId,
  }) async {
    final snapshot = await _col
        .where('studentId', isEqualTo: studentId)
        .where('interpreterId', isEqualTo: interpreterId)
        .where('status', whereIn: ['pending', 'confirmed']).get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get all bookings for a student
  Stream<List<Map<String, dynamic>>> bookingsForStudent(String studentId) {
    Get.log('BookingService: Query bookings for studentId: $studentId');
    return _col
        .where('studentId', isEqualTo: studentId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snap) {
      Get.log(
          'BookingService: Found ${snap.docs.length} bookings for student $studentId');
      return snap.docs.map((d) {
        final data = {'id': d.id, ...d.data()};
        Get.log(
            '  - Booking ${d.id}: status=${data['status']}, interpreterId=${data['interpreterId']}');
        return data;
      }).toList();
    });
  }

  /// Get all bookings for an interpreter
  Stream<List<Map<String, dynamic>>> bookingsForInterpreter(
      String interpreterId) {
    return _col
        .where('interpreterId', isEqualTo: interpreterId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Debug: Get ALL bookings (for troubleshooting)
  Future<void> debugPrintAllBookings() async {
    final snapshot = await _col.get();
    Get.log('=== ALL BOOKINGS IN DATABASE ===');
    for (var doc in snapshot.docs) {
      final data = doc.data();
      Get.log('Booking ${doc.id}:');
      Get.log('  studentId: ${data['studentId']}');
      Get.log('  interpreterId: ${data['interpreterId']}');
      Get.log('  status: ${data['status']}');
      Get.log('  studentName: ${data['studentName'] ?? 'NOT SET'}');
      Get.log('  interpreterName: ${data['interpreterName'] ?? 'NOT SET'}');
    }
    Get.log('=== END OF ALL BOOKINGS ===');
  }

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _col.doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'cancelled');
  }

  /// Confirm a booking
  Future<void> confirmBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'confirmed');
  }

  /// Complete a booking (after video call ends)
  Future<void> completeBooking(String bookingId) async {
    await _col.doc(bookingId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get a single booking by ID
  Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final doc = await _col.doc(bookingId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      Get.log('Error getting booking $bookingId: $e');
      return null;
    }
  }

  /// Update booking with rating
  Future<void> updateBookingRating(String bookingId, int rating) async {
    await _col.doc(bookingId).update({
      'rating': rating,
      'ratedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update interpreter's average rating
  Future<void> updateInterpreterRating(
      String interpreterId, int newRating) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(interpreterId);

      // Get all completed bookings for this interpreter with ratings
      final bookingsSnapshot = await _col
          .where('interpreterId', isEqualTo: interpreterId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Calculate new average rating
      final ratingsWithNew = bookingsSnapshot.docs
          .map((doc) => doc.data()['rating'] as int?)
          .where((r) => r != null && r > 0)
          .cast<int>()
          .toList();

      ratingsWithNew.add(newRating);

      final averageRating = ratingsWithNew.isEmpty
          ? 0.0
          : ratingsWithNew.reduce((a, b) => a + b) / ratingsWithNew.length;

      // Update interpreter's rating field
      await userDoc.update({
        'rating': averageRating,
        'totalRatings': ratingsWithNew.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.log(
          'Updated interpreter $interpreterId rating to $averageRating (${ratingsWithNew.length} ratings)');
    } catch (e) {
      Get.log('Error updating interpreter rating: $e');
      rethrow;
    }
  }
}
