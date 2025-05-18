import 'package:flutter/material.dart';
import 'package:gym/models/package.dart';
import 'package:gym/providers/admin/package_provider.dart';
import 'package:provider/provider.dart';

class PackageManagementScreen extends StatefulWidget {
  const PackageManagementScreen({super.key});

  @override
  State<PackageManagementScreen> createState() =>
      _PackageManagementScreenState();
}

class _PackageManagementScreenState extends State<PackageManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PackageProvider>(context, listen: false).loadPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 23, 25, 53),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 25, 53),
        title: const Text(
          'Üyelik Paketleri',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Yeni Paket Ekle',
              onPressed: () => _showPackageDialog(context),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: Consumer<PackageProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (provider.packages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Henüz paket eklenmemiş',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showPackageDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(255, 23, 25, 53),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'PAKET EKLE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.packages.length,
              itemBuilder: (context, index) {
                final package = provider.packages[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      package.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        if (package.description != null &&
                            package.description!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              package.description!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${package.price} TL',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${package.durationDays} Gün',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      color: const Color.fromARGB(255, 23, 25, 53),
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Düzenle',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.red[300],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sil',
                                    style: TextStyle(color: Colors.red[300]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showPackageDialog(context, package);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, package);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showPackageDialog(
    BuildContext context, [
    PackageModel? package,
  ]) {
    final nameController = TextEditingController(text: package?.name);
    final descController = TextEditingController(text: package?.description);
    final priceController = TextEditingController(
      text: package?.price.toString(),
    );
    final daysController = TextEditingController(
      text: package?.durationDays.toString(),
    );

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 23, 25, 53),
            title: Text(
              package == null ? 'Yeni Paket' : 'Paketi Düzenle',
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, 'Paket Adı'),
                  const SizedBox(height: 16),
                  _buildTextField(descController, 'Açıklama'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    priceController,
                    'Fiyat (TL)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    daysController,
                    'Süre (Gün)',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'İptal',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final newPackage = PackageModel(
                    id: package?.id,
                    name: nameController.text,
                    description: descController.text,
                    price:
                        (double.tryParse(priceController.text) ?? 0).toString(),
                    durationDays: (int.tryParse(daysController.text) ?? 30),
                  );

                  final provider = Provider.of<PackageProvider>(
                    context,
                    listen: false,
                  );

                  if (package == null) {
                    provider.addPackage(newPackage);
                  } else {
                    provider.updatePackage(package.id!, newPackage);
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color.fromARGB(255, 23, 25, 53),
                ),
                child: Text(package == null ? 'Ekle' : 'Güncelle'),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, PackageModel package) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 23, 25, 53),
            title: const Text(
              'Paketi Sil',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              '${package.name} paketini silmek istediğinize emin misiniz?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'İptal',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<PackageProvider>(
                    context,
                    listen: false,
                  ).deletePackage(package.id!);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red[300]),
                child: const Text('Sil'),
              ),
            ],
          ),
    );
  }
}
