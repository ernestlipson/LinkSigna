import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChatFirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get messages for a specific booking
  /// Returns messages ordered by timestamp descending (newest first)
  Stream<List<Map<String, dynamic>>> getMessagesStream(String bookingId) {
    Get.log('ChatService: Listening to messages for booking: $bookingId');
    
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100) // Limit to last 100 messages for performance
        .snapshots()
        .map((snapshot) {
      Get.log('ChatService: Received ${snapshot.docs.length} messages');
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Send a message in a booking chat
  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String senderName,
    required String senderRole, // 'student' or 'interpreter'
    required String messageText,
  }) async {
    try {
      Get.log('ChatService: Sending message to booking: $bookingId');
      
      final messageData = {
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .collection('messages')
          .add(messageData);

      // Update last message info on the booking document
      await _firestore.collection('bookings').doc(bookingId).update({
        'lastMessage': messageText,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageBy': senderRole,
      });

      Get.log('ChatService: Message sent successfully');
    } catch (e) {
      Get.log('ChatService: Error sending message: $e');
      rethrow;
    }
  }

  /// Check if chat is still active (within 24 hours of booking completion)
  Future<bool> isChatActive(String bookingId) async {
    try {
      final bookingDoc =
          await _firestore.collection('bookings').doc(bookingId).get();

      if (!bookingDoc.exists) {
        Get.log('ChatService: Booking not found');
        return false;
      }

      final data = bookingDoc.data();
      if (data == null) return false;

      // Check if booking is completed
      if (data['status'] != 'completed') {
        Get.log('ChatService: Booking not completed');
        return false;
      }

      // Check if completedAt timestamp exists
      final completedAt = data['completedAt'] as Timestamp?;
      if (completedAt == null) {
        Get.log('ChatService: No completion timestamp');
        return false;
      }

      // Check if within 24 hours
      final completionDate = completedAt.toDate();
      final now = DateTime.now();
      final difference = now.difference(completionDate);
      final isActive = difference.inHours < 24;

      Get.log(
          'ChatService: Chat active status: $isActive (${difference.inHours} hours since completion)');
      return isActive;
    } catch (e) {
      Get.log('ChatService: Error checking chat active status: $e');
      return false;
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String bookingId,
    required String currentUserId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      Get.log('ChatService: Marked ${snapshot.docs.length} messages as read');
    } catch (e) {
      Get.log('ChatService: Error marking messages as read: $e');
    }
  }

  /// Get unread message count for a booking
  Future<int> getUnreadCount({
    required String bookingId,
    required String currentUserId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      Get.log('ChatService: Error getting unread count: $e');
      return 0;
    }
  }

  /// Delete all messages for a booking (optional cleanup)
  Future<void> deleteMessages(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      Get.log('ChatService: Deleted ${snapshot.docs.length} messages');
    } catch (e) {
      Get.log('ChatService: Error deleting messages: $e');
      rethrow;
    }
  }
}
