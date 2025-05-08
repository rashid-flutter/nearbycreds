class Profile {
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String? profileImageUrl;
  final String? role;
  final int? coins; // Add coins field

  // Constructor
  Profile({
    required this.userId,
    required this.name,
    this.role,
    required this.phone,
    required this.email,
    this.profileImageUrl,
    this.coins, // Initialize coins field
  });

  // Factory method to create a Profile from Firestore data
  factory Profile.fromFirestore(Map<String, dynamic> data) {
    return Profile(
      userId: data['userId'],
      name: data['name'] ?? 'No Name',
      phone: data['phone'] ?? 'No Phone',
      email: data['email'] ?? 'No Email',
      role: data['role'] ?? 'No role',
      profileImageUrl: data['profileImageUrl'],
      coins: data['coins'] ?? 0, // Default coins to 0 if not present
    );
  }

  // Method to convert Profile object to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'coins': coins, // Include coins in the map
    };
  }
}
