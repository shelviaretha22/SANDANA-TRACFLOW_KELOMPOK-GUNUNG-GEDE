class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String department;
  final String? phone;
  final String? photoPath;
  final String? createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.department,
    this.phone,
    this.photoPath,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      department: map['department'],
      phone: map['phone'],
      photoPath: map['photo_path'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'department': department,
      'phone': phone,
      'photo_path': photoPath,
      'created_at': createdAt,
    };
  }
}