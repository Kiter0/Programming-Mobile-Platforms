class UserEntity {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.image,
  });

  String get fullName => '$firstName $lastName'.trim();
}