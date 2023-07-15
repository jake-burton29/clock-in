class UserData {
  final String uid;
  final String email;
  final bool isAdmin;
  final bool isActive; // Add this

  UserData({
    required this.uid,
    required this.email,
    required this.isAdmin,
    required this.isActive, // And this
  });

  // Convert a UserData object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'isAdmin': isAdmin,
      'isActive': isActive, // And this
    };
  }

  // Create a UserData object from a map (from Firestore)
  factory UserData.fromMap(Map<String, dynamic> map, String id) {
    return UserData(
      uid: id,
      email: map['email'],
      isAdmin: map['isAdmin'],
      isActive: map['isActive'] ?? true, // And this
    );
  }
}
