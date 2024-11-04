class UserModel {
  final String id;
  final String username;
  final String name;
  final String department;
  final String password;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.department,
    required this.password,
  });

  // Method untuk konversi data dari dan ke Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'department': department,
      'password': password,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      password: map['password'] ?? '',
    );
  }
}
