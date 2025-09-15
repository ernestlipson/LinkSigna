// A simple model for your Interpreter data
import 'package:cloud_firestore/cloud_firestore.dart';

class Interpreter {
  final String id; // This will be the document ID
  final String firstName;
  final String lastName;
  final String email;
  final String profileAvatar;
  final String description;
  final double price;
  final String sessionId;
  final bool isBooked;

  Interpreter({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileAvatar,
    required this.description,
    required this.price,
    required this.sessionId,
    required this.isBooked,
  });

  // Factory constructor to create an Interpreter from a Firestore DocumentSnapshot
  factory Interpreter.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Interpreter(
      id: doc.id,
      firstName: data['firstname'] ?? '',
      lastName: data['lastname'] ?? '',
      email: data['email'] ?? '',
      profileAvatar: data['profileAvatar'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      sessionId: data['session_id'] ?? '',
      isBooked: data['isBooked'] ?? false,
    );
  }

  // Method to convert Interpreter object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'profileAvatar': profileAvatar,
      'description': description,
      'price': price,
      'session_id': sessionId,
      'isBooked': isBooked,
    };
  }
}
