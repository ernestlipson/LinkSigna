// A simple model for your Interpreter data
import 'package:cloud_firestore/cloud_firestore.dart';

class Interpreter {
  final String id; // This will be the document ID
  final String interpreterId; // interpreter_id from Firestore
  final String firstName;
  final String lastName;
  final String email;
  final String profilePictureUrl;
  final bool isAvailable;
  final DateTime? joinedDate;
  final List<dynamic> languages;
  final double rating;
  final List<dynamic> specializations;
  final DateTime? updatedAt;

  Interpreter({
    required this.id,
    required this.interpreterId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePictureUrl,
    required this.isAvailable,
    required this.joinedDate,
    required this.languages,
    required this.rating,
    required this.specializations,
    required this.updatedAt,
  });

  factory Interpreter.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return Interpreter(
      id: doc.id,
      interpreterId: data['interpreter_id'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      joinedDate: parseDate(data['joinedDate']),
      languages: data['languages'] ?? [],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      specializations: data['specializations'] ?? [],
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'interpreter_id': interpreterId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'isAvailable': isAvailable,
      'joinedDate': joinedDate,
      'languages': languages,
      'rating': rating,
      'specializations': specializations,
      'updatedAt': updatedAt,
    };
  }
}
