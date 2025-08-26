class UserEntity {
  final String id;
  final String? name;
  final String? email;
  final bool? emailVerification;

  UserEntity({
    required this.id,
    this.name,
    this.email,
    this.emailVerification,
  });
}
