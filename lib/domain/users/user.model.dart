import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, interpreter }

class User {
  final String uid;
  final String? authUid;
  final UserRole role;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? university;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? universityLevel;
  final String? language;

  final List<String>? languages;
  final List<String>? specializations;
  final double? rating;
  final bool? isAvailable;
  final String? experience;
  final int? years;

  User({
    required this.uid,
    this.authUid,
    required this.role,
    this.displayName,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.university,
    this.createdAt,
    this.updatedAt,
    this.universityLevel,
    this.language,
    this.languages,
    this.specializations,
    this.rating,
    this.isAvailable,
    this.experience,
    this.years,
  });

  bool get isStudent => role == UserRole.student;
  bool get isInterpreter => role == UserRole.interpreter;

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return displayName ?? '';
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final roleString = data['role'] as String?;
    final role =
        roleString == 'interpreter' ? UserRole.interpreter : UserRole.student;

    final firstName = data['firstname'] ?? data['firstName'];
    final lastName = data['lastname'] ?? data['lastName'];
    final combinedName = firstName != null && lastName != null
        ? '$firstName $lastName'.trim()
        : null;

    return User(
      uid: doc.id,
      authUid: data['authUid'],
      role: role,
      displayName: combinedName ?? data['displayName'],
      firstName: firstName,
      lastName: lastName,
      email: data['email'],
      phone: data['phone'],
      avatarUrl: data['avatarUrl'] ?? data['profilePictureUrl'],
      bio: data['bio'],
      university: data['university'],
      universityLevel: data['university_level'] ?? data['universityLevel'],
      language: data['language'],
      languages: data['languages'] != null
          ? List<String>.from(data['languages'])
          : null,
      specializations: data['specializations'] != null
          ? List<String>.from(data['specializations'])
          : null,
      rating: data['rating']?.toDouble(),
      isAvailable: data['isAvailable'],
      experience: data['experience'],
      years: data['years'],
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    final map = <String, dynamic>{
      'role': role == UserRole.interpreter ? 'interpreter' : 'student',
      'authUid': authUid,
      'email': email,
      'phone': phone,
      'bio': bio,
      'university': university,
      if (!isUpdate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (firstName != null && lastName != null) {
      map['firstname'] = firstName;
      map['lastname'] = lastName;
    } else if (displayName != null) {
      final nameParts = displayName!.split(' ');
      map['firstname'] = nameParts.isNotEmpty ? nameParts.first : '';
      map['lastname'] = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    }

    if (role == UserRole.student) {
      map['university_level'] = universityLevel;
      map['language'] = language;
      map['avatarUrl'] = avatarUrl;
    } else if (role == UserRole.interpreter) {
      map['languages'] = languages ?? [];
      map['specializations'] = specializations ?? [];
      map['rating'] = rating ?? 0.0;
      map['isAvailable'] = isAvailable ?? false;
      map['profilePictureUrl'] = avatarUrl;
      map['experience'] = experience;
      map['years'] = years;
    }

    map.removeWhere((key, value) => value == null);
    return map;
  }

  User copyWith({
    String? authUid,
    String? displayName,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? university,
    String? universityLevel,
    String? language,
    List<String>? languages,
    List<String>? specializations,
    double? rating,
    bool? isAvailable,
    String? experience,
    int? years,
  }) {
    return User(
      uid: uid,
      authUid: authUid ?? this.authUid,
      role: role,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      university: university ?? this.university,
      universityLevel: universityLevel ?? this.universityLevel,
      language: language ?? this.language,
      languages: languages ?? this.languages,
      specializations: specializations ?? this.specializations,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
      experience: experience ?? this.experience,
      years: years ?? this.years,
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
