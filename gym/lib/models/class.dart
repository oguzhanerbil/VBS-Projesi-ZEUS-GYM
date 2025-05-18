class Class {
  final int id; // ders_id
  final String name; // ders_adi
  final String? description; // açıklama (ER diyagramda yok ama ekleyebiliriz)
  final String dayOfWeek; // gun (ER diyagramda VARCHAR(20) olarak tanımlanmış)
  final String startTime; // saat
  final String endTime; // hesaplanan bitiş saati
  final int durationMinutes; // sure_dakika
  final int trainerId; // egitmen_id
  final String? trainerName; // egitmen adı soyadı (JOIN)
  final int capacity; // max_kapasite
  final String? location; // lokasyon
  final String? status; // aktiflik

  Class({
    required this.id,
    required this.name,
    this.description,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.trainerId,
    this.trainerName,
    required this.capacity,
    this.location,
    this.status = 'Aktif',
  });

  factory Class.fromMap(Map<String, dynamic> map) {
    return Class(
      id: map['ders_id'] ?? 0,
      name: map['ders_adi'] ?? '',
      description: map['description'] ?? map['aciklama'],
      dayOfWeek: map['gun'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      durationMinutes: map['sure_dakika'] ?? 0,
      trainerId: map['trainerId'] ?? map['kullanici_id'] ?? 0,
      capacity: map['capacity'] ?? map['max_kapasite'] ?? 0,
      location: map['location'] ?? map['lokasyon'],
      status: map['status'] ?? map['aktiflik'] ?? 'Aktif',
      trainerName: map['trainerName'] ?? map['egitmen_adi'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ders_id': id,
      'ders_adi': name,
      'gun': dayOfWeek,
      'saat': timeRange,
      'baslangic_saati': startTime,
      'bitis_saati': endTime,
      'sure_dakika': durationMinutes,
      'kullanici_id': trainerId,
      'max_kapasite': capacity,
      'lokasyon': location ?? '',
      'aktiflik': status ?? 'Aktif',
      'trainerName': trainerName ?? '',
    };
  }

  // Saat aralığını döndüren getter
  String get timeRange => '$startTime - $endTime';
}
