class Attendance {
  final int id; // katilim_id
  final int classId; // ders_id
  final int memberId; // uye_id
  final String status; // durum ('Geldi', 'Gelmedi', 'İptal')
  final DateTime date; // tarih
  final String? memberName; // üye adı (JOIN ile alınmış)

  Attendance({
    required this.id,
    required this.classId,
    required this.memberId,
    required this.status,
    required this.date,
    this.memberName,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['katilim_id'] ?? map['id'] ?? 0,
      classId: map['ders_id'] ?? map['classId'] ?? 0,
      memberId: map['uye_id'] ?? map['memberId'] ?? 0,
      status: map['durum'] ?? map['status'] ?? 'Gelmedi',
      date: DateTime.parse(
        map['tarih'] ?? map['date'] ?? DateTime.now().toString(),
      ),
      memberName: map['memberName'] ?? map['ad_soyad'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'katilim_id': id,
      'ders_id': classId,
      'uye_id': memberId,
      'durum': status,
      'tarih': date.toString(),
    };
  }

  Attendance copyWith({
    int? id,
    int? classId,
    int? memberId,
    String? status,
    DateTime? date,
    String? memberName,
  }) {
    return Attendance(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      memberId: memberId ?? this.memberId,
      status: status ?? this.status,
      date: date ?? this.date,
      memberName: memberName ?? this.memberName,
    );
  }

  bool get isPresent => status == 'Geldi';
}
