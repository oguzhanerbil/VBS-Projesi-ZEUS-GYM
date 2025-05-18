class User {
  final int id;
  final String email;
  final String name; // Eklendi
  final String surname; // Eklendi
  final String role;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.name, // Eklendi
    required this.surname, // Eklendi
    this.lastLogin,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id:
          map['kullanici_id'] != null
              ? int.parse(map['kullanici_id'].toString())
              : 0,
      email: map['email'] ?? '',
      name: map['ad'] ?? '',
      surname: map['soyad'] ?? '',
      role: map['rol'] ?? '',
      lastLogin:
          map['lastLogin'] != null
              ? DateTime.parse(map['lastLogin'].toString())
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kullanici_id': id,
      'email': email,
      'rol': role,
      'son_giris': lastLogin?.toIso8601String(),
      'ad': name,
      'soyad': surname,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, role: $role, lastLogin: $lastLogin, ad: $name, soyad: $surname)';
  }
}
