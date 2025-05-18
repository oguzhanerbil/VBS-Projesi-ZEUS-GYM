import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/membership_package.dart';
import '../../providers/member_provider.dart';
import '../../config/routes.dart';

class MembershipPackagesScreen extends StatefulWidget {
  const MembershipPackagesScreen({super.key});

  @override
  State<MembershipPackagesScreen> createState() =>
      _MembershipPackagesScreenState();
}

class _MembershipPackagesScreenState extends State<MembershipPackagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMembershipPackages();
    });
  }

  Future<void> _loadMembershipPackages() async {
    final provider = Provider.of<MemberProvider>(context, listen: false);
    await provider.loadMembershipPackages();
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
        child: Consumer<MemberProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingPackages) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (provider.packages.isEmpty) {
              return const Center(
                child: Text(
                  'Üyelik paketi bulunamadı',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.packages.length,
              itemBuilder: (context, index) {
                final package = provider.packages[index];
                return _buildPackageCard(package);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPackageCard(MembershipPackage package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              package.packageName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (package.description != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  package.description!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed(Routes.payment, arguments: package);
                  },
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
                    'SATIN AL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
