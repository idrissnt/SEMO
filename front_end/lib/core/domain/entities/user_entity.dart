class User {
  final String id;
  final String email;
  final String firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePhotoUrl,
    this.createdAt,
  });

  String get fullName => '$firstName ${lastName ?? ''}';
}
