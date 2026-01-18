class AuthUser {
  final String uid;
  final String? name;
  final String? email;
  final String? photo;

  AuthUser({
    required this.uid,
    this.name,
    this.email,
    this.photo,
  });
}
