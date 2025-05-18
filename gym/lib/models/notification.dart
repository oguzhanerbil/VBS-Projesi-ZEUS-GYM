class GymNotification {
  final int id; // bildirim_id
  final int memberId; // uye_id
  final String content; // icerik
  final bool isRead; // okundu
  final DateTime sentDate; // gonderim_tarihi
  final String? memberName; // üye adı (JOIN)

  GymNotification({
    required this.id,
    required this.memberId,
    required this.content,
    required this.isRead,
    required this.sentDate,
    this.memberName,
  });

  factory GymNotification.fromMap(Map<String, dynamic> map) {
    return GymNotification(
      id: map['bildirim_id'] ?? 0,
      memberId: map['uye_id'] ?? 0,
      content: map['icerik'] ?? '',
      isRead: map['okundu'] == 1,
      sentDate: DateTime.parse(
        map['gonderim_tarihi'] ?? DateTime.now().toString(),
      ),
      memberName: map['member_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bildirim_id': id,
      'uye_id': memberId,
      'icerik': content,
      'okundu': isRead ? 1 : 0,
      'gonderim_tarihi': sentDate.toString(),
    };
  }

  // copyWith metodu eklendi
  GymNotification copyWith({
    int? id,
    int? memberId,
    String? content,
    bool? isRead,
    DateTime? sentDate,
    String? memberName,
  }) {
    return GymNotification(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      sentDate: sentDate ?? this.sentDate,
      memberName: memberName ?? this.memberName,
    );
  }
}
