class Payment {
  final int id;
  final int memberId;
  final int paymentTypeId;
  final String? paymentTypeName; // odeme_turu.ad
  final double amount;
  final String description;
  final DateTime paymentDate;
  final String? memberName; // JOIN ile gelen üye adı

  Payment({
    required this.id,
    required this.memberId,
    required this.paymentTypeId,
    this.paymentTypeName,
    required this.amount,
    required this.description,
    required this.paymentDate,
    this.memberName,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      memberId: map['uye_id'],
      paymentTypeId: map['odeme_turu_id'],
      paymentTypeName: map['odeme_turu'],
      amount:
          map['tutar'] is int
              ? (map['tutar'] as int).toDouble()
              : map['tutar'] ?? 0.0,
      description: map['aciklama'] ?? '',
      paymentDate:
          map['odeme_tarihi'] != null
              ? DateTime.parse(map['odeme_tarihi'])
              : DateTime.now(),
      memberName: map['ad_soyad'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uye_id': memberId,
      'odeme_turu_id': paymentTypeId,
      'tutar': amount,
      'aciklama': description,
      'odeme_tarihi': paymentDate.toIso8601String(),
    };
  }

  Payment copyWith({
    int? id,
    int? memberId,
    int? paymentTypeId,
    String? paymentTypeName,
    double? amount,
    String? description,
    DateTime? paymentDate,
    String? memberName,
  }) {
    return Payment(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      paymentTypeName: paymentTypeName ?? this.paymentTypeName,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentDate: paymentDate ?? this.paymentDate,
      memberName: memberName ?? this.memberName,
    );
  }

  // Ödeme tarihini formatla
  String get formattedDate {
    return '${paymentDate.day}/${paymentDate.month}/${paymentDate.year}';
  }

  // Tutarı formatla
  String get formattedAmount {
    return '₺${amount.toStringAsFixed(2)}';
  }
}
