import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/member_provider.dart';
import '../../models/member.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMembers();
    });
  }

  Future<void> _loadMembers() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    await memberProvider.loadActiveMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üye Listesi'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMembers),
        ],
      ),
      body: Consumer<MemberProvider>(
        builder: (context, memberProvider, child) {
          if (memberProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (memberProvider.error != null) {
            return Center(child: Text('Hata: ${memberProvider.error}'));
          }

          final members = memberProvider.membersList;

          if (members.isEmpty) {
            return const Center(child: Text('Henüz üye bulunmuyor.'));
          }

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ListTile(
                  title: Text(member.firstName),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog(context, member);
                    },
                  ),
                  onTap: () {
                    // Detaylı üye bilgisi gösterilebilir
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni üye ekleme sayfasına git
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Member member) async {
    final nameController = TextEditingController(text: member.firstName);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Üye Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ad Soyad'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                final memberProvider = Provider.of<MemberProvider>(
                  context,
                  listen: false,
                );
                final success = await memberProvider.updateMember(
                  member.id,
                  nameController.text,
                );

                if (context.mounted) {
                  Navigator.of(context).pop();

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Güncelleme hatası: ${memberProvider.error}',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Üye bilgileri güncellendi'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
}
