class User {
  final String id;
  final String email;
  final String firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profilePhotoUrl;
  final DateTime? createdAt;
  final bool isGuest;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePhotoUrl,
    this.createdAt,
    this.isGuest = false,
  });

  /// Factory constructor to create a guest user
  /// This allows parts of the app to be accessed without authentication
  factory User.guest() => User(
        id: 'guest',
        email: 'guest@semo.win',
        firstName: 'Guest',
        isGuest: true,
      );

  String get fullName => '$firstName ${lastName ?? ''}';
  
  /// Whether this user requires authentication for protected features
  bool get requiresAuthentication => !isGuest;
}
