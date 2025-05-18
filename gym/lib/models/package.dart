class PackageModel {
  final int? id;
  final String name;
  final String? description;
  final String price;
  final int durationDays;
  final bool isActive;

  PackageModel({
    this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationDays,
    this.isActive = true,
  });

  factory PackageModel.fromMap(Map<String, dynamic> map) {
    return PackageModel(
      id: map['paket_id'],
      name: map['paket_adi'],
      description: map['aciklama'],
      price: map['fiyat'],
      durationDays: map['sure_gun'],
      isActive: map['aktif'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paket_adi': name,
      'aciklama': description,
      'fiyat': price,
      'sure_gun': durationDays,
      'aktif': isActive ? 1 : 0,
    };
  }
}
