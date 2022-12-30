class Profile {
  Profile({
    required this.id,
    required this.username,
    required this.createdAt,
    this.firstName,
    this.lastName,
    this.avatarURL
  });

  // User ID of the profile
  final String id;

  // Username of the profile
  final String username;

  // Date and time when the profile was created
  final DateTime createdAt;

  // First name of user
  String? firstName;

  // Last name of user
  String? lastName;

  // Avatar URL
  String? avatarURL; 


  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']),
        firstName = map['first_name'],
        lastName = map['last_name'],
        avatarURL = map['avatar_url'];


  String? getName(){
    if(firstName == null || lastName == null){
      return null;
    }
    return '$firstName $lastName';
  }

  void updateProfile({required firstName, required lastName, required avatarURL}) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.avatarURL = avatarURL;
  }
}