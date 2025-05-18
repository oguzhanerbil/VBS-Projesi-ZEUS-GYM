class Member {
  final int id; // uye_id
  final int userId; // kullanici_id
  final String firstName; // ad
  final String lastName; // soyad
  final DateTime? birthDate; // dogum_tarihi
  final String? address; // adres
  final DateTime membershipStart; // uyelik_baslangic
  final DateTime? membershipEnd; // uyelik_bitis
  final String membershipStatus; // uyelik_durumu

  // Kullanici tablosundan gelen alanlar
  final String email; // email
  final String role; // rol
  final DateTime lastLogin; // son_giris

  // Paket bilgileri
  final String? packageName; // Paket adı
  final double price; // Fiyat

  String get fullName => '$firstName $lastName';

  Member({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.address,
    required this.membershipStart,
    this.membershipEnd,
    required this.membershipStatus,
    required this.email,
    required this.role,
    required this.lastLogin,
    required this.packageName,
    required this.price,
  });

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['uye_id'] ?? 0,
      userId: map['kullanici_id'] ?? 0,
      firstName: map['ad'] ?? '',
      lastName: map['soyad'] ?? '',
      birthDate:
          map['dogum_tarihi'] != null
              ? _parseDateTime(map['dogum_tarihi'])
              : null,
      address: map['adres'],
      membershipStart:
          map['uyelik_baslangic'] != null
              ? _parseDateTime(map['uyelik_baslangic'])
              : DateTime.now(),
      membershipEnd:
          map['uyelik_bitis'] != null
              ? _parseDateTime(map['uyelik_bitis'])
              : null,
      membershipStatus: map['uyelik_durumu'] ?? 'Aktif',

      email: map['email'] ?? '',
      role: map['rol'] ?? 'Uye',
      lastLogin:
          map['son_giris'] != null
              ? _parseDateTime(map['son_giris'])
              : DateTime.now(),
      packageName: map['paket_adi'] ?? 'Standart',
      price: double.tryParse(map['fiyat'].toString()) ?? 0.0,
    );
  }

  // Yardımcı metod - String veya DateTime'ı güvenli şekilde DateTime'a dönüştürür
  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;

    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      print('Tarih dönüşüm hatası: $e, değer: $value');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uye_id': id,
      'kullanici_id': userId,
      'ad': firstName,
      'soyad': lastName,
      'dogum_tarihi': birthDate?.toString(),
      'adres': address,
      'uyelik_baslangic': membershipStart.toString(),
      'uyelik_bitis': membershipEnd?.toString(),
      'uyelik_durumu': membershipStatus,
      'paket_adi': packageName,
      'fiyat': price,
    };
  }
}
