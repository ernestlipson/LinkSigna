// // DEPRECATED: This model has been replaced by the unified User model
// // at lib/domain/users/user.model.dart
// // Use User model instead for all interpreter-related operations.
// //
// // A simple model for your Interpreter data from unified users collection
// import 'package:cloud_firestore/cloud_firestore.dart';

// @Deprecated('Use User model from domain/users/user.model.dart instead')
// class Interpreter {
//   final String id; // This will be the document ID (uid from User model)
//   final String
//       interpreterId; // authUid or uid - kept for backwards compatibility
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String profilePictureUrl;
//   final bool isAvailable;
//   final DateTime? joinedDate;
//   final List<dynamic> languages;
//   final double rating;
//   final List<dynamic> specializations;
//   final DateTime? updatedAt;

//   Interpreter({
//     required this.id,
//     required this.interpreterId,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.profilePictureUrl,
//     required this.isAvailable,
//     required this.joinedDate,
//     required this.languages,
//     required this.rating,
//     required this.specializations,
//     required this.updatedAt,
//   });

//   factory Interpreter.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map<String, dynamic>;
//     DateTime? parseDate(dynamic value) {
//       if (value == null) return null;
//       if (value is Timestamp) return value.toDate();
//       if (value is String) {
//         try {
//           return DateTime.parse(value);
//         } catch (_) {
//           return null;
//         }
//       }
//       return null;
//     }

//     // Handle both old and new field names for compatibility
//     String firstName = data['firstName'] ?? '';
//     String lastName = data['lastName'] ?? '';
//     final displayName = data['displayName'] as String?;

//     // Priority: Use firstName/lastName if available, otherwise parse displayName
//     if ((firstName.isEmpty && lastName.isEmpty) &&
//         displayName != null &&
//         displayName.isNotEmpty) {
//       final parts = displayName.trim().split(' ');
//       if (parts.isNotEmpty) {
//         firstName = parts.first;
//         lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
//       }
//     } else if (firstName.isEmpty && lastName.isEmpty && displayName == null) {
//       // Fallback to email username if nothing else available
//       final email = data['email'] as String?;
//       if (email != null && email.isNotEmpty) {
//         firstName = email.split('@').first;
//       }
//     }

//     return Interpreter(
//       id: doc.id,
//       interpreterId: data['authUid'] ?? data['interpreter_id'] ?? doc.id,
//       firstName: firstName,
//       lastName: lastName,
//       email: data['email'] ?? '',
//       profilePictureUrl: data['avatarUrl'] ?? data['profilePictureUrl'] ?? '',
//       isAvailable: data['isAvailable'] ?? false,
//       joinedDate: parseDate(data['joinedDate'] ?? data['createdAt']),
//       languages: data['languages'] ?? [],
//       rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
//       specializations: data['specializations'] ?? [],
//       updatedAt: parseDate(data['updatedAt']),
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'role': 'interpreter',
//       'authUid': interpreterId,
//       'firstName': firstName,
//       'lastName': lastName,
//       'displayName': '$firstName $lastName'.trim(),
//       'email': email,
//       'avatarUrl': profilePictureUrl,
//       'isAvailable': isAvailable,
//       'joinedDate': joinedDate,
//       'languages': languages,
//       'rating': rating,
//       'specializations': specializations,
//       'updatedAt': updatedAt,
//       'createdAt': joinedDate ?? DateTime.now(),
//     };
//   }
// }
