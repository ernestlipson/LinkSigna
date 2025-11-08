// import 'package:cloud_firestore/cloud_firestore.dart';

// class StudentUser {
//   final String uid;
//   final String? authUid;
//   final String role;
//   final String? displayName;
//   final String? email;
//   final String? phone;
//   final String? avatarUrl;
//   final String? bio;
//   final String? university;
//   final String? universityLevel;
//   final String? language;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   StudentUser({
//     required this.uid,
//     this.authUid,
//     this.role = 'student',
//     this.displayName,
//     this.email,
//     this.phone,
//     this.avatarUrl,
//     this.bio,
//     this.university,
//     this.universityLevel,
//     this.language,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory StudentUser.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>? ?? {};

//     final firstName = data['firstname'] ?? '';
//     final lastName = data['lastname'] ?? '';
//     final combinedName = '$firstName $lastName'.trim();

//     return StudentUser(
//       uid: doc.id,
//       authUid: data['authUid'],
//       role: data['role'] ?? 'student',
//       displayName: combinedName.isNotEmpty ? combinedName : data['displayName'],
//       email: data['email'],
//       phone: data['phone'],
//       avatarUrl: data['avatarUrl'],
//       bio: data['bio'],
//       university: data['university'],
//       universityLevel: data['university_level'],
//       language: data['language'],
//       createdAt: _toDate(data['createdAt']),
//       updatedAt: _toDate(data['updatedAt']),
//     );
//   }

//   Map<String, dynamic> toMap({bool isUpdate = false}) {
//     final nameParts = displayName?.split(' ') ?? [];
//     final firstName = nameParts.isNotEmpty ? nameParts.first : '';
//     final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

//     return {
//       'role': role,
//       'authUid': authUid,
//       'firstname': firstName,
//       'lastname': lastName,
//       'email': email,
//       'phone': phone,
//       'avatarUrl': avatarUrl,
//       'bio': bio,
//       'university': university,
//       'university_level': universityLevel,
//       'language': language,
//       if (!isUpdate) 'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }..removeWhere((key, value) => value == null);
//   }

//   StudentUser copyWith({
//     String? displayName,
//     String? email,
//     String? phone,
//     String? avatarUrl,
//     String? bio,
//     String? university,
//     String? universityLevel,
//     String? language,
//     String? authUid,
//   }) {
//     return StudentUser(
//       uid: uid,
//       authUid: authUid ?? this.authUid,
//       role: role,
//       displayName: displayName ?? this.displayName,
//       email: email ?? this.email,
//       phone: phone ?? this.phone,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//       bio: bio ?? this.bio,
//       university: university ?? this.university,
//       universityLevel: universityLevel ?? this.universityLevel,
//       language: language ?? this.language,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//     );
//   }

//   static DateTime? _toDate(dynamic v) {
//     if (v is Timestamp) return v.toDate();
//     if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
//     return null;
//   }
// }
