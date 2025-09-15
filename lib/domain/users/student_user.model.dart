import 'package:cloud_firestore/cloud_firestore.dart';

class StudentUser {
  final String uid; // Firestore document id (auto generated)
  final String? authUid; // Firebase Auth UID reference
  final String role; // always 'student'
  final String? displayName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? universityLevel; // e.g. Level 400
  final String? language; // e.g. Ghanaian Sign Language
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentUser({
    required this.uid,
    this.authUid,
    this.role = 'student',
    this.displayName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.universityLevel,
    this.language,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StudentUser(
      uid: doc.id,
      authUid: data['authUid'],
      role: data['role'] ?? 'student',
      displayName: data['displayName'],
      email: data['email'],
      phone: data['phone'],
      avatarUrl: data['avatarUrl'],
      bio: data['bio'],
      universityLevel: data['university_level'],
      language: data['language'],
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'role': role,
      'authUid': authUid,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'university_level': universityLevel,
      'language': language,
      if (!isUpdate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }..removeWhere((key, value) => value == null);
  }

  StudentUser copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? universityLevel,
    String? language,
    String? authUid,
  }) {
    return StudentUser(
      uid: uid,
      authUid: authUid ?? this.authUid,
      role: role,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      universityLevel: universityLevel ?? this.universityLevel,
      language: language ?? this.language,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _toDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }
}
