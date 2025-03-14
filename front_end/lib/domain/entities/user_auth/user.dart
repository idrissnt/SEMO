class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profileImage;
  final DateTime createdAt;
  final String? address;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profileImage,
    required this.createdAt,
    this.address,
  });

  String get fullName => '$firstName $lastName';
}
