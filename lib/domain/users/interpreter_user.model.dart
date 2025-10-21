import 'package:cloud_firestore/cloud_firestore.dart';

class InterpreterUser {
  final String interpreterID;
  final String? authUid;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? university;
  final List<String> languages;
  final List<String> specializations;
  final double rating;
  final String? bio;
  final bool isAvailable;
  final String? profilePictureUrl;
  final DateTime? joinedDate;
  final DateTime? updatedAt;

  InterpreterUser({
    required this.interpreterID,
    this.authUid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.university,
    this.languages = const [],
    this.specializations = const [],
    this.rating = 0.0,
    this.bio,
    this.isAvailable = false,
    this.profilePictureUrl,
    this.joinedDate,
    this.updatedAt,
  });

  String get displayName => '$firstName $lastName';

  factory InterpreterUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return InterpreterUser(
      interpreterID: doc.id,
      authUid: data['authUid'],
      firstName: data['firstname'] ?? '',
      lastName: data['lastname'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      university: data['university'],
      languages: List<String>.from(data['languages'] ?? []),
      specializations: List<String>.from(data['specializations'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      bio: data['bio'],
      isAvailable: data['isAvailable'] ?? false,
      profilePictureUrl: data['profilePictureUrl'],
      joinedDate: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'role': 'interpreter',
      'authUid': authUid,
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'phone': phone,
      'university': university,
      'languages': languages,
      'specializations': specializations,
      'rating': rating,
      'bio': bio,
      'isAvailable': isAvailable,
      'profilePictureUrl': profilePictureUrl,
      if (!isUpdate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }..removeWhere((key, value) => value == null);
  }

  InterpreterUser copyWith({
    String? authUid,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? university,
    List<String>? languages,
    List<String>? specializations,
    double? rating,
    String? bio,
    bool? isAvailable,
    String? profilePictureUrl,
  }) {
    return InterpreterUser(
      interpreterID: interpreterID,
      authUid: authUid ?? this.authUid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      university: university ?? this.university,
      languages: languages ?? this.languages,
      specializations: specializations ?? this.specializations,
      rating: rating ?? this.rating,
      bio: bio ?? this.bio,
      isAvailable: isAvailable ?? this.isAvailable,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      joinedDate: joinedDate,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _toDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }
}
