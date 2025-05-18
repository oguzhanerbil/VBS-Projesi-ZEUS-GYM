class MembershipPackage {
  final int id;
  final int memberId;
  final int packageTypeId;
  final String packageName;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final double price;

  MembershipPackage({
    required this.id,
    required this.memberId,
    required this.packageTypeId,
    required this.packageName,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.price,
  });

  factory MembershipPackage.fromMap(Map<String, dynamic> map) {
    int parseIntSafely(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      try {
        return int.parse(value.toString());
      } catch (e) {
        print('Sayı dönüştürme hatası ($value): $e');
        return 0;
      }
    }

    return MembershipPackage(
      id: parseIntSafely(map['paket_id']),
      memberId: parseIntSafely(map['uye_id']),
      packageTypeId: parseIntSafely(map['paket_turu_id']),
      packageName: map['paket_adi']?.toString() ?? '',
      description: map['aciklama']?.toString(),
      startDate:
          map['baslangic_tarihi'] != null
              ? DateTime.parse(map['baslangic_tarihi'].toString())
              : DateTime.now(),
      endDate:
          map['bitis_tarihi'] != null
              ? DateTime.parse(map['bitis_tarihi'].toString())
              : DateTime.now().add(const Duration(days: 30)),
      amount:
          map['odeme_tutari'] != null
              ? double.tryParse(map['odeme_tutari'].toString()) ?? 0.0
              : 0.0,
      price: (double.tryParse(map['fiyat'].toString()) ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uye_id': memberId,
      'paket_turu_id': packageTypeId,
      'baslangic_tarihi': startDate.toIso8601String(),
      'bitis_tarihi': endDate.toIso8601String(),
      'odeme_tutari': amount,
      'paket_adi': packageName,
      'aciklama': description,
      'fiyat': price,
    };
  }

  MembershipPackage copyWith({
    int? id,
    int? memberId,
    int? packageTypeId,
    String? packageName,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? amount,
  }) {
    return MembershipPackage(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      packageTypeId: packageTypeId ?? this.packageTypeId,
      packageName: packageName ?? this.packageName,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
      price: price,
    );
  }

  // Üyeliğin aktif olup olmadığını kontrol et
  bool get isActive {
    final now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now);
  }

  // Kalan gün sayısını hesapla
  int get remainingDays {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }
}
