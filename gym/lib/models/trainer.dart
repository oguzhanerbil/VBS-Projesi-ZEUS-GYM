import 'user.dart';

class Trainer {
  final int id;
  final int userId;
  final User user;
  final String phone;
  final String? specialization;
  final String? biography;
  final DateTime hireDate;

  Trainer({
    required this.id,
    required this.userId,
    required this.user,
    required this.phone,
    this.specialization,
    this.biography,
    required this.hireDate,
  });

  factory Trainer.fromMap(Map<String, dynamic> map) {
    // Kullanıcı bilgilerini doğrudan mevcut map'ten alır
    final user = User(
      id: map['kullanici_id'] ?? map['id'],
      email: map['email'],
      role: map['rol'] ?? 'egitmen',
      name: map['ad'],
      surname: map['soyad'],
    );

    return Trainer(
      id: map['id'] ?? map['kullanici_id'],
      userId: user.id,
      user: user,
      phone: map['telefon'] ?? '',
      specialization: map['uzmanlik_alani'],
      biography: map['biyografi'],
      hireDate:
          map['ise_giris_tarihi'] != null
              ? DateTime.parse(map['ise_giris_tarihi'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kullanici_id': userId,
      'telefon': phone,
      'uzmanlik_alani': specialization,
      'biyografi': biography,
      'ise_giris_tarihi': hireDate.toIso8601String(),
    };
  }

  Trainer copyWith({
    int? id,
    int? userId,
    User? user,
    String? phone,
    String? specialization,
    String? biography,
    DateTime? hireDate,
  }) {
    return Trainer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      biography: biography ?? this.biography,
      hireDate: hireDate ?? this.hireDate,
    );
  }
}
