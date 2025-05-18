class EntryRecord {
  final int id; // giris_id
  final int memberId; // uye_id
  final DateTime dateTime; // tarih_saat
  final String entryType; // giris_tipi ('QR', 'Manuel', 'Parmakizi')
  final String? memberName; // üye adı (JOIN)

  EntryRecord({
    required this.id,
    required this.memberId,
    required this.dateTime,
    required this.entryType,
    this.memberName,
  });

  factory EntryRecord.fromMap(Map<String, dynamic> map) {
    return EntryRecord(
      id: map['giris_id'] ?? 0,
      memberId: map['uye_id'] ?? 0,
      dateTime: DateTime.parse(map['tarih_saat'] ?? DateTime.now().toString()),
      entryType: map['giris_tipi'] ?? 'Manuel',
      memberName: map['member_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'giris_id': id,
      'uye_id': memberId,
      'tarih_saat': dateTime.toString(),
      'giris_tipi': entryType,
    };
  }
}
