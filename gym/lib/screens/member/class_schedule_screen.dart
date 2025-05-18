import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../models/class.dart';

class ClassScheduleScreen extends StatefulWidget {
  const ClassScheduleScreen({super.key});

  @override
  State<ClassScheduleScreen> createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends State<ClassScheduleScreen> {
  @override
  void initState() {
    super.initState();
    // Build işleminden sonra veri yüklemeyi başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClasses();
    });
  }

  Future<void> _loadClasses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      await classProvider.loadMemberClasses(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 23, 25, 53),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 25, 53),
        title: const Text(
          'Ders Programı',
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
        child: Consumer<ClassProvider>(
          builder: (context, classProvider, child) {
            if (classProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (classProvider.error != null) {
              return Center(
                child: Text(
                  'Hata: ${classProvider.error}',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }

            final classes = classProvider.memberClasses;

            if (classes.isEmpty) {
              return const Center(
                child: Text(
                  'Bu hafta için uygun ders bulunamadı.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            // Günlere göre dersleri grupla
            final groupedClasses = <String, List<Class>>{};
            for (final cls in classes) {
              if (groupedClasses[cls.dayOfWeek] == null) {
                groupedClasses[cls.dayOfWeek] = [];
              }
              groupedClasses[cls.dayOfWeek]!.add(cls);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedClasses.keys.length,
              itemBuilder: (context, index) {
                final day = groupedClasses.keys.elementAt(index);
                final dayClasses = groupedClasses[day]!;
                final dayName = dayClasses.first.dayOfWeek;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        dayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dayClasses.length,
                      itemBuilder: (context, classIndex) {
                        final cls = dayClasses[classIndex];
                        return ClassItemCard(
                          cls: cls,
                          onJoin: () => _joinClass(cls),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _joinClass(Class cls) async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await classProvider.addAttendance(
      cls.id,
      authProvider.currentUser!.id,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Derse başarıyla kaydoldunuz.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Derse kayıt olurken hata: ${classProvider.error}'),
        ),
      );
    }
  }
}

class ClassItemCard extends StatelessWidget {
  final Class cls;
  final VoidCallback onJoin;

  const ClassItemCard({super.key, required this.cls, required this.onJoin});

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cls.startTime} - ${cls.endTime}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    cls.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cls.trainerName ?? 'Bilinmeyen Eğitmen',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: onJoin,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'KATIL',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (cls.description != null && cls.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cls.description!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
