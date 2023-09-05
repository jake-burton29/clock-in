class UserData {
  final String uid;
  final String email;
  final bool isAdmin;
  final bool isActive;

  UserData({
    required this.uid,
    required this.email,
    required this.isAdmin,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'isAdmin': isAdmin,
      'isActive': isActive, // And this
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map, String id) {
    return UserData(
      uid: id,
      email: map['email'],
      isAdmin: map['isAdmin'],
      isActive: map['isActive'] ?? true,
    );
  }
}
