import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin/admin_provider.dart';
import '../../config/routes.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          image: DecorationImage(
            image: const AssetImage('assets/images/background.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık ve Çıkış butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Admin Paneli',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        // TODO: Çıkış işlemi
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(Routes.login);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Yönetim menüsü başlığı
                const Text(
                  'Yönetim Menüsü',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Menü kartları
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildMenuCard(
                        context: context,
                        title: 'Üye Yönetimi',
                        icon: Icons.people,
                        route: Routes.memberManagement,
                      ),
                      _buildMenuCard(
                        context: context,
                        title: 'Paket Yönetimi',
                        icon: Icons.card_membership,
                        route: Routes.packageManagement,
                      ),
                      _buildMenuCard(
                        context: context,
                        title: 'Eğitmen Yönetimi',
                        icon: Icons.sports,
                        route: Routes.trainerManagement,
                      ),
                      _buildMenuCard(
                        context: context,
                        title: 'Ders Programı',
                        icon: Icons.calendar_today,
                        route: Routes.classScheduleManagement,
                      ),
                      _buildMenuCard(
                        context: context,
                        title: 'Admin Listesi',
                        icon: Icons.admin_panel_settings,
                        onTap: () {
                          final adminProvider = Provider.of<AdminProvider>(
                            context,
                            listen: false,
                          );
                          adminProvider.loadAdmins();
                          _showAdminList(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(Routes.registerAdmin),
        backgroundColor: const Color.fromARGB(255, 23, 25, 53),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    String? route,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.1),
      child: InkWell(
        onTap:
            onTap ??
            (route != null
                ? () => Navigator.of(context).pushNamed(route)
                : null),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAdminList(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 23, 25, 53),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Consumer<AdminProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }

              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Admin Listesi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.admins.length,
                      itemBuilder: (context, index) {
                        final admin = provider.admins[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            '${admin.name} ${admin.surname}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            admin.email,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            'Son Giriş: ${_formatDate(admin.lastLogin)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Belirsiz';
    return '${date.day}/${date.month}/${date.year}';
  }
}
