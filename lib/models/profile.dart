class Profile {
  Profile({
    required this.id,
    required this.username,
    required this.createdAt,
    this.firstName,
    this.lastName
  });

  // User ID of the profile
  final String id;

  // Username of the profile
  final String username;

  // Date and time when the profile was created
  final DateTime createdAt;

  // First name of user
  final String? firstName;

  // Last name of user
  final String? lastName;

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']),
        firstName = map['first_name'],
        lastName = map['last_name'];
}