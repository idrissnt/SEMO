class UserAddress {
  final String addressId;
  final String userId;
  final int streetNumber;
  final String streetName;
  final String city;
  final int zipCode;
  final String country;

  UserAddress({
    required this.addressId,
    required this.userId,
    required this.streetNumber,
    required this.streetName,
    required this.city,
    required this.zipCode,
    required this.country,
  });
}
